# 🚀 TOPLA Backend API

Yandex Go uslubidagi yetkazib berish tizimi bilan marketplace backend.

## Tech Stack

- **Node.js 20+** + **TypeScript**
- **Fastify** — tez HTTP framework
- **Prisma** — type-safe ORM
- **PostgreSQL** — ma'lumotlar bazasi
- **Redis** — cache va session
- **Socket.IO** — real-time (GPS tracking)
- **Firebase Admin** — OTP + push notification

## 📁 Project Structure

```
topla-backend/
├── prisma/
│   ├── schema.prisma     # Database schema
│   └── seed.ts           # Initial data
├── src/
│   ├── config/           # App configuration
│   │   ├── env.ts        # Environment variables
│   │   ├── database.ts   # Prisma client
│   │   ├── firebase.ts   # Firebase Admin SDK
│   │   └── storage.ts    # S3 client (Yandex Object Storage)
│   ├── middleware/       # Fastify middleware
│   │   ├── auth.ts       # JWT authentication
│   │   └── error.ts      # Error handling
│   ├── modules/          # Feature modules
│   │   ├── auth/         # Login, register, profile
│   │   ├── products/     # Products, cart, favorites
│   │   ├── shops/        # Shops, reviews
│   │   ├── orders/       # Orders (Yandex Go flow)
│   │   ├── courier/      # Courier system
│   │   ├── notifications/# Push + in-app
│   │   ├── addresses/    # User addresses
│   │   └── banners/      # Home banners
│   ├── websocket/        # Socket.IO
│   │   └── socket.ts     # Real-time tracking
│   ├── utils/            # Helpers
│   │   └── jwt.ts        # JWT utils
│   └── app.ts            # Entry point
├── nginx/                # Nginx config
├── docker-compose.yml    # Docker setup
├── Dockerfile            # Production image
└── package.json
```

## 🚀 Quick Start (Local Development)

### 1. Prerequisites

```bash
# Node.js 20+
node -v  # v20.x.x

# PostgreSQL
psql --version

# pnpm (recommended) or npm
npm install -g pnpm
```

### 2. Setup

```bash
# Clone va kirish
cd topla-backend

# Dependencies
pnpm install

# Environment
cp .env.example .env
# .env ni to'ldiring

# Database yaratish
createdb topla_db

# Prisma generate
pnpm db:generate

# Database migrate
pnpm db:push

# Seed data
pnpm db:seed
```

### 3. Run

```bash
# Development (hot reload)
pnpm dev

# Production build
pnpm build
pnpm start
```

Server: `http://localhost:3000`

## 📡 API Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/login` | Firebase OTP login |
| POST | `/api/v1/auth/refresh` | Token refresh |
| GET | `/api/v1/auth/me` | Current user |
| PUT | `/api/v1/auth/profile` | Update profile |
| POST | `/api/v1/auth/fcm-token` | Update FCM token |
| POST | `/api/v1/auth/logout` | Logout |

### Products
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/products` | List (filter, search, sort) |
| GET | `/api/v1/products/:id` | Product detail |
| GET | `/api/v1/products/featured` | Featured products |
| GET | `/api/v1/categories` | Categories + subcategories |
| GET | `/api/v1/brands` | Brands |
| GET | `/api/v1/colors` | Colors |

### Cart
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/cart` | Get cart |
| POST | `/api/v1/cart` | Add to cart |
| PUT | `/api/v1/cart/:productId` | Update quantity |
| DELETE | `/api/v1/cart/:productId` | Remove item |
| DELETE | `/api/v1/cart` | Clear cart |

### Favorites
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/favorites` | List favorites |
| POST | `/api/v1/favorites/:productId` | Add to favorites |
| DELETE | `/api/v1/favorites/:productId` | Remove |

### Shops
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/shops` | List shops |
| GET | `/api/v1/shops/:id` | Shop detail |
| GET | `/api/v1/shops/:id/products` | Shop products |
| GET | `/api/v1/shops/:id/reviews` | Shop reviews |
| POST | `/api/v1/shops/:id/reviews` | Add review |

### Orders (Customer)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/orders` | Create order |
| GET | `/api/v1/orders` | My orders |
| GET | `/api/v1/orders/:id` | Order detail |
| POST | `/api/v1/orders/:id/cancel` | Cancel order |
| POST | `/api/v1/orders/:id/rate` | Rate delivery |

### Orders (Vendor)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/vendor/orders` | Vendor orders |
| PUT | `/api/v1/vendor/orders/:id/status` | Update status |

### Courier
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/courier/register` | Register as courier |
| GET | `/api/v1/courier/me` | Courier profile |
| PUT | `/api/v1/courier/status` | Online/offline |
| POST | `/api/v1/courier/location` | Update GPS |
| GET | `/api/v1/courier/orders/available` | Available deliveries |
| GET | `/api/v1/courier/orders/active` | Active delivery |
| GET | `/api/v1/courier/orders/history` | Delivery history |
| POST | `/api/v1/courier/orders/:id/accept` | Accept delivery |
| POST | `/api/v1/courier/orders/:id/reject` | Reject delivery |
| POST | `/api/v1/courier/orders/:id/picked-up` | Mark picked up |
| POST | `/api/v1/courier/orders/:id/start-delivery` | Start delivery |
| POST | `/api/v1/courier/orders/:id/delivered` | Mark delivered |
| GET | `/api/v1/courier/earnings` | Earnings stats |

### Notifications
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/notifications` | List notifications |
| PUT | `/api/v1/notifications/:id/read` | Mark as read |
| PUT | `/api/v1/notifications/read-all` | Mark all read |
| GET | `/api/v1/notifications/unread-count` | Unread count |

## 🔌 WebSocket Events

### Connection
```javascript
const socket = io('wss://api.topla.uz', {
  path: '/ws',
  auth: { token: 'JWT_TOKEN' }
});
```

### Customer Events
```javascript
// Buyurtmani kuzatish
socket.emit('track:order', orderId);

// Kuryer joylashuvi
socket.on('tracking:location', (data) => {
  // { courierId, latitude, longitude, speed, heading, timestamp }
});

// Status o'zgarishi
socket.on('order:status-changed', (data) => {
  // { orderId, status, timestamp }
});
```

### Courier Events
```javascript
// Online bo'lish
socket.emit('courier:online', courierId);

// GPS yuborish
socket.emit('courier:location', {
  courierId,
  orderId, // (optional) faol buyurtma bo'lsa
  latitude,
  longitude,
  speed,
  heading
});

// Yangi yetkazma taklifi
socket.on('delivery:offer', (offer) => {
  // { orderId, orderNumber, shopName, distanceKm, estimatedMinutes, expiresAt }
});
```

### Vendor Events
```javascript
// Buyurtmalarni kuzatish
socket.emit('vendor:watch-orders');

// Yangi buyurtma
socket.on('order:new', (data) => {
  // { order, timestamp }
});
```

## 🐳 Docker Deployment

### Development
```bash
docker-compose up -d
```

### Production
```bash
# Build
docker build -t topla-backend .

# Run
docker run -d \
  --name topla-api \
  -p 3000:3000 \
  --env-file .env.production \
  topla-backend
```

## ☁️ Yandex Cloud Deployment

### 1. Compute Cloud VM yaratish
- Ubuntu 22.04
- 2 vCPU, 4GB RAM (minimum)
- 20GB SSD

### 2. VM ga kirish
```bash
ssh -i ~/.ssh/yc_key ubuntu@<VM_IP>
```

### 3. Docker o'rnatish
```bash
sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
```

### 4. Deploy
```bash
git clone https://github.com/YOUR_REPO/topla-backend.git
cd topla-backend
cp .env.example .env
# .env ni to'ldiring (Yandex Cloud credentials)
docker-compose up -d
```

### 5. SSL (Let's Encrypt)
```bash
sudo apt install certbot
sudo certbot certonly --standalone -d api.topla.uz
# Sertifikatlarni nginx/ssl/ ga ko'chiring
```

## 📊 Order Status Flow

```
pending → confirmed → processing → ready_for_pickup
                                        ↓
              delivered ← shipping ← courier_picked_up ← courier_assigned
```

| Status | Kim o'zgartiradi | Keyingi |
|--------|-----------------|---------|
| `pending` | System | `confirmed` / `cancelled` |
| `confirmed` | Vendor | `processing` |
| `processing` | Vendor | `ready_for_pickup` |
| `ready_for_pickup` | Vendor | `courier_assigned` (auto) |
| `courier_assigned` | Courier | `courier_picked_up` |
| `courier_picked_up` | Courier | `shipping` |
| `shipping` | Courier | `delivered` |
| `delivered` | Courier | — (final) |
| `cancelled` | Customer/Vendor | — (final) |

## 📱 Push Notifications

Har bir status o'zgarishda tegishli tomonga push yuboriladi:

| Status | Mijoz | Vendor | Kuryer |
|--------|-------|--------|--------|
| `pending` (new) | ✅ | ✅ | — |
| `confirmed` | ✅ | — | — |
| `processing` | ✅ | — | — |
| `ready_for_pickup` | — | — | ✅ |
| `courier_assigned` | ✅ | ✅ | — |
| `courier_picked_up` | ✅ | ✅ | — |
| `shipping` | ✅ | — | — |
| `delivered` | ✅ | ✅ | — |
| `cancelled` | ✅ | ✅ | ✅ |

## 🔒 Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | ✅ | PostgreSQL connection string |
| `JWT_SECRET` | ✅ | JWT signing secret |
| `FIREBASE_PROJECT_ID` | ⚠️ | Firebase project ID (for push) |
| `FIREBASE_PRIVATE_KEY` | ⚠️ | Firebase private key |
| `FIREBASE_CLIENT_EMAIL` | ⚠️ | Firebase service email |
| `S3_ENDPOINT` | ⚡ | Yandex Object Storage endpoint |
| `S3_ACCESS_KEY` | ⚡ | S3 access key |
| `S3_SECRET_KEY` | ⚡ | S3 secret key |
| `REDIS_URL` | ⚡ | Redis connection (optional) |

✅ Required | ⚠️ Required for push | ⚡ Optional

## 📄 License

MIT © 2026 TOPLA
