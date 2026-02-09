# TOPLA Web Deployment Qo'llanma

## Domen tuzilmasi

- **topla.uz** - Asosiy landing sahifa
- **admin.topla.uz** - Admin panel
- **vendor.topla.uz** - Sotuvchi portali

## Web Build

```bash
# Asosiy build
flutter build web --release

# Build folder: build/web
```

## Vercel bilan Deploy

### 1. Vercel CLI o'rnatish
```bash
npm i -g vercel
```

### 2. Project sozlash

**vercel.json** fayli:
```json
{
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
      ]
    }
  ]
}
```

### 3. Deploy qilish
```bash
cd build/web
vercel --prod
```

## Firebase Hosting bilan Deploy

### 1. Firebase CLI o'rnatish
```bash
npm install -g firebase-tools
```

### 2. Firebase initialize
```bash
firebase init hosting
```

**firebase.json**:
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### 3. Deploy
```bash
flutter build web --release
firebase deploy --only hosting
```

## Subdomen sozlash (Nginx misol)

```nginx
# topla.uz - Landing
server {
    listen 80;
    server_name topla.uz www.topla.uz;
    root /var/www/topla/web;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}

# admin.topla.uz - Admin Panel
server {
    listen 80;
    server_name admin.topla.uz;
    root /var/www/topla/web;
    
    location / {
        try_files $uri $uri/ /index.html;
        # Admin route'ga yo'naltirish
        rewrite ^/$ /admin redirect;
    }
}

# vendor.topla.uz - Vendor Portal
server {
    listen 80;
    server_name vendor.topla.uz;
    root /var/www/topla/web;
    
    location / {
        try_files $uri $uri/ /index.html;
        # Vendor route'ga yo'naltirish
        rewrite ^/$ /vendor redirect;
    }
}
```

## Route'lar

| Route | Sahifa | Tavsif |
|-------|--------|--------|
| `/` | WebLandingPage | Asosiy landing sahifa |
| `/admin` | WebAdminLoginScreen | Admin login |
| `/admin/dashboard` | WebAdminDashboard | Admin panel |
| `/vendor` | WebVendorLanding | Sotuvchi landing |
| `/vendor/login` | WebVendorLogin | Sotuvchi login |
| `/vendor/register` | WebVendorRegister | Ro'yxatdan o'tish |
| `/vendor/dashboard` | VendorDashboardScreen | Sotuvchi panel |

## Mobile Ilovadan Web'ga yo'naltirish

Ilova ichida admin/vendor panellar o'rniga brauzerda web sahifalar ochiladi:
- Admin panel: `https://admin.topla.uz`
- Vendor panel: `https://vendor.topla.uz`
- Do'kon ochish: `https://vendor.topla.uz/register`

## Environment Variables

Supabase va Firebase sozlamalari:
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key
- Firebase config - `firebase_options.dart` da
