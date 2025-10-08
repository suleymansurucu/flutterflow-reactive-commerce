import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/supabase/supabase.dart';

String? queryBuilder(List<String>? conditions) {
  if (conditions == null || conditions.isEmpty) return '';

  String enc(String v) => Uri.encodeQueryComponent(v);

  // Parse a single raw condition into (column, op, value)
  // Accepts either "col=op.value" or "col:value:op" formats.
  ({String column, String op, String value})? parse(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    // Primary format: "col=op.value"
    if (s.contains('=') && s.contains('.')) {
      final lr = s.split('=');
      if (lr.length != 2) return null;
      final column = lr[0].trim();
      final opVal = lr[1].trim();
      final dot = opVal.indexOf('.');
      if (dot <= 0) return null;
      final op = opVal.substring(0, dot).trim().toLowerCase();
      final value = opVal.substring(dot + 1).trim();
      if (column.isEmpty || op.isEmpty) return null;
      return (column: column, op: op, value: value);
    }

    // Fallback format: "col:value:op"
    final parts = s.split(':');
    if (parts.length < 3) return null;
    final column = parts[0].trim();
    final value = parts[1].trim();
    final op = parts[2].trim().toLowerCase();
    if (column.isEmpty || op.isEmpty) return null;
    return (column: column, op: op, value: value);
  }

  // Build a single PostgREST filter fragment like "col=op.value"
  String buildOne(String column, String op, String value) {
    switch (op) {
      case 'eq':
      case 'gt':
      case 'lt':
      case 'gte':
      case 'lte':
      case 'neq':
      case 'not.like':
        return '$column=$op.${enc(value)}';

      case 'like':
      case 'ilike':
        // If caller didn't include wildcards, wrap with *...*
        final pattern = value.contains('*') ? value : '*$value*';
        final safe =
            pattern.replaceAllMapped(RegExp(r'[^*]+'), (m) => enc(m.group(0)!));
        return '$column=$op.$safe';

      case 'is':
        // e.g. "col=is.null"
        return '$column=is.${enc(value)}';

      case 'in':
        // Normalize to "col=in.(A,B,...)"
        // Accepts "(A,B)" or "A,B" and URL-encodes each item.
        final raw = value.startsWith('(')
            ? value.substring(1, value.length - 1)
            : value;
        final items = raw
            .split(',')
            .map((e) => enc(e.trim()))
            .where((e) => e.isNotEmpty)
            .toList();
        return '$column=in.(${items.join(",")})';

      default:
        return '';
    }
  }

  // Parse all incoming conditions
  final parsed = <({String column, String op, String value})>[];
  for (final c in conditions) {
    final p = parse(c);
    if (p != null) parsed.add(p);
  }
  if (parsed.isEmpty) return '';

  // Group conditions by column
  final Map<String, List<({String op, String value})>> byCol = {};
  for (final p in parsed) {
    byCol.putIfAbsent(p.column, () => []);
    byCol[p.column]!.add((op: p.op, value: p.value));
  }

  final out = <String>[];

  byCol.forEach((column, ops) {
    // 1) OR within the same column for multiple EQs → use IN(...)
    final eqVals = <String>{};
    for (final e in ops) {
      if (e.op == 'eq') eqVals.add(e.value);
    }
    if (eqVals.length > 1) {
      final encoded = eqVals.map((v) => Uri.encodeQueryComponent(v)).join(',');
      out.add('$column=in.($encoded)');
    } else if (eqVals.length == 1) {
      // Single EQ remains a normal "eq"
      final v = eqVals.first;
      out.add('$column=eq.${enc(v)}');
    }

    // 2) AND within the same column for ranges → add both sides if present
    //    (gte/gt) AND (lte/lt)
    for (final e in ops.where((e) => e.op == 'gt' || e.op == 'gte')) {
      out.add(buildOne(column, e.op, e.value));
    }
    for (final e in ops.where((e) => e.op == 'lt' || e.op == 'lte')) {
      out.add(buildOne(column, e.op, e.value));
    }

    // 3) Other operators for the same column (neq, like, ilike, not.like, is, in)
    //    are also ANDed with the rest.
    for (final e in ops.where((e) =>
        e.op != 'eq' &&
        e.op != 'gt' &&
        e.op != 'gte' &&
        e.op != 'lt' &&
        e.op != 'lte')) {
      final f = buildOne(column, e.op, e.value);
      if (f.isNotEmpty) out.add(f);
    }
  });

  // IMPORTANT: Do NOT prepend '?'. Return only the query fragments joined by '&'.
  // The caller or FlutterFlow can prepend '?' when assembling the final URL.
  return out.isEmpty ? '' : out.join('&');
}
