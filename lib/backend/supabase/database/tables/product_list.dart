import '../database.dart';

class ProductListTable extends SupabaseTable<ProductListRow> {
  @override
  String get tableName => 'product_list';

  @override
  ProductListRow createRow(Map<String, dynamic> data) => ProductListRow(data);
}

class ProductListRow extends SupabaseDataRow {
  ProductListRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProductListTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  double? get price => getField<double>('price');
  set price(double? value) => setField<double>('price', value);

  double? get capacity => getField<double>('capacity');
  set capacity(double? value) => setField<double>('capacity', value);

  double? get pricePerCapacity => getField<double>('price_per_capacity');
  set pricePerCapacity(double? value) =>
      setField<double>('price_per_capacity', value);

  double? get warranty => getField<double>('warranty');
  set warranty(double? value) => setField<double>('warranty', value);

  String? get formFactor => getField<String>('form_factor');
  set formFactor(String? value) => setField<String>('form_factor', value);

  String? get tech => getField<String>('tech');
  set tech(String? value) => setField<String>('tech', value);

  String? get condition => getField<String>('condition');
  set condition(String? value) => setField<String>('condition', value);

  String? get link => getField<String>('link');
  set link(String? value) => setField<String>('link', value);
}
