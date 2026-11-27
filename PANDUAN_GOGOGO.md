# Panduan Lengkap GoGoGo SuperApp

Aplikasi **GoGoGo SuperApp** (Food, Mart, Express, Pay, Rewards, & Asisten AI) dilengkapi dengan **Portal Pelanggan**, **Dashboard Merchant (`/restoran-saya`)**, **Dashboard Kurir (`/kurir`)**, dan **Super Admin Panel (`/admin`)**.

- **Nama Brand:** GoGoGo
- **Alamat Kantor:** BTN Bawah Abepura
- **Customer Service / Support:** `08215006669`

---

## 1. Jalankan Lokal di Komputer
Klik dua kali file **[`JALANKAN_SUPERAPP.bat`](file:///c:/Users/ellyas.martadinata/Downloads/courier-android-main/gogogo-superapp/JALANKAN_SUPERAPP.bat)** untuk membuka aplikasi secara lokal di `http://127.0.0.1:8080`.

## 2. Database Supabase Cloud
1. Buka **SQL Editor** Supabase Anda:
   `https://supabase.com/dashboard/project/ugigyjrmmtsegpfjkjea/sql/new`
2. Salin & jalankan seluruh isi file **[`supabase/AKTIFKAN_DATA_DAN_ADMIN.sql`](file:///c:/Users/ellyas.martadinata/Downloads/courier-android-main/gogogo-superapp/supabase/AKTIFKAN_DATA_DAN_ADMIN.sql)**.
3. Matikan opsi **Confirm email** di menu **Authentication → Sign In / Providers → Email**.

## 3. Deploy ke Cloudflare Pages (100% Bersih Tanpa Watermark)
1. Buka dashboard **Cloudflare Pages** Anda dan pilih **Upload assets / Create new deployment**.
2. Unggah file **[`gogogo-deploy.zip`](file:///c:/Users/ellyas.martadinata/Downloads/courier-android-main/gogogo-deploy.zip)** lalu klik **Deploy site**.
3. Untuk membuka panel pengembang tersembunyi kapan saja, tekan **`Ctrl + Shift + G`** di keyboard atau tambahkan **`/?panel=1`** di akhir alamat URL.
