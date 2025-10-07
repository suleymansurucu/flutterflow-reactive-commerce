# 🛍️ FluxCart — Reactive One-Page E-Commerce App
> Built with **FlutterFlow**, **Flutter**, and **Supabase** — a real-time single-page shopping experience.

## 🚀 Overview
**FluxCart** is a reactive one-page e-commerce application demonstrating a modern architecture using **Supabase** as the backend and **FlutterFlow** for rapid UI development. It delivers a seamless, real-time shopping experience — from product browsing to checkout — within a single reactive screen.

## ✨ Features
- 🔄 Realtime cart updates across sessions and devices  
- 🧾 Single-page flow: catalog → cart → checkout  
- 🔐 Supabase Auth (Email / OAuth ready)  
- 📦 Server-side RPC & RLS policies for secure data access  
- 🧠 Reactive UI built in FlutterFlow (Custom Widgets + Actions)  
- 🧩 Modular architecture: clean separation of data, domain, and UI layers  

## 🧰 Tech Stack
| Layer | Technology | Description |
|--------|-------------|-------------|
| UI | FlutterFlow + Flutter | Visual builder with custom Dart code |
| Backend | Supabase | Auth, DB, Realtime, RLS, RPC |
| State | Reactive Streams + Local Cache | Real-time updates |
| Design | Material 3 + Responsive Layout | Adaptive across mobile/web |

## 🏗️ Architecture

```bash
lib/
 ├── app/                # entry, router, theme
 ├── features/
 │    ├── catalog/       # product list, filters
 │    ├── cart/          # reactive cart management
 │    ├── checkout/      # order summary & payment
 │    └── auth/          # supabase auth integration
 ├── data/
 │    ├── models/
 │    ├── sources/       # supabase queries, rpc
 │    └── repos/
 ├── custom_code/        # FlutterFlow custom widgets/actions
 └── main.dart
```


**Patterns used:** Repository + Data Source pattern, clean modular features, stream-based reactive updates, and FlutterFlow export safe zones for custom logic.

## 🗄️ Supabase Setup
1. Create a project at [supabase.com](https://supabase.com)  
2. Create tables:
   - `products (id, name, price, image_url)`
   - `cart_items (id, user_id, product_id, quantity)`
   - `profiles (id, name, email)`
3. Enable **Row Level Security (RLS)** and policies:
   ```sql
   create policy "user_owns_cart"
   on cart_items for all
   using (auth.uid() = user_id);

