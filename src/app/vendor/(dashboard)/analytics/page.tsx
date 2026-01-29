'use client'

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'

// Mock data
const monthlyData = [
  { month: 'Yan', revenue: 12500000, orders: 15 },
  { month: 'Fev', revenue: 18700000, orders: 23 },
  { month: 'Mar', revenue: 22300000, orders: 28 },
  { month: 'Apr', revenue: 19800000, orders: 25 },
  { month: 'May', revenue: 28500000, orders: 35 },
  { month: 'Iyn', revenue: 32100000, orders: 42 },
]

const topProducts = [
  { name: 'iPhone 15 Pro Max', sold: 45, revenue: 715500000 },
  { name: 'Samsung Galaxy S24', sold: 38, revenue: 475000000 },
  { name: 'MacBook Pro M3', sold: 12, revenue: 384000000 },
  { name: 'AirPods Pro', sold: 65, revenue: 169000000 },
  { name: 'iPad Pro 12.9', sold: 18, revenue: 324000000 },
]

const recentOrders = [
  { id: 'ORD-156', customer: 'Abdulloh K.', amount: 15900000, date: 'Bugun' },
  { id: 'ORD-155', customer: 'Malika R.', amount: 12500000, date: 'Bugun' },
  { id: 'ORD-154', customer: 'Jasur T.', amount: 32000000, date: 'Kecha' },
  { id: 'ORD-153', customer: 'Nodira A.', amount: 2600000, date: 'Kecha' },
]

export default function VendorAnalyticsPage() {
  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('uz-UZ').format(price) + ' so\'m'
  }

  const totalRevenue = monthlyData.reduce((sum, m) => sum + m.revenue, 0)
  const totalOrders = monthlyData.reduce((sum, m) => sum + m.orders, 0)
  const avgOrderValue = totalRevenue / totalOrders

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Analitika</h1>
          <p className="text-muted-foreground">
            Do'koningiz statistikasi va tahlili
          </p>
        </div>
        <Select defaultValue="6months">
          <SelectTrigger className="w-40">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="7days">Oxirgi 7 kun</SelectItem>
            <SelectItem value="30days">Oxirgi 30 kun</SelectItem>
            <SelectItem value="6months">Oxirgi 6 oy</SelectItem>
            <SelectItem value="year">Bu yil</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Summary Stats */}
      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Jami daromad</CardTitle>
            <span className="text-2xl">💰</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatPrice(totalRevenue)}</div>
            <p className="text-xs text-green-600">+12.5% o'tgan oydan</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Jami buyurtmalar</CardTitle>
            <span className="text-2xl">📦</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{totalOrders}</div>
            <p className="text-xs text-green-600">+8.2% o'tgan oydan</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">O'rtacha chek</CardTitle>
            <span className="text-2xl">📊</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatPrice(avgOrderValue)}</div>
            <p className="text-xs text-green-600">+3.1% o'tgan oydan</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Konversiya</CardTitle>
            <span className="text-2xl">📈</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">4.2%</div>
            <p className="text-xs text-red-600">-0.3% o'tgan oydan</p>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        {/* Revenue Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Daromad dinamikasi</CardTitle>
            <CardDescription>Oylik daromad ko'rsatkichlari</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {monthlyData.map((month) => (
                <div key={month.month} className="flex items-center gap-4">
                  <div className="w-12 text-sm font-medium">{month.month}</div>
                  <div className="flex-1">
                    <div className="h-8 bg-gray-100 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-gradient-to-r from-blue-500 to-blue-600 rounded-full transition-all"
                        style={{ width: `${(month.revenue / 35000000) * 100}%` }}
                      />
                    </div>
                  </div>
                  <div className="w-28 text-right text-sm font-medium">
                    {formatPrice(month.revenue)}
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Orders Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Buyurtmalar soni</CardTitle>
            <CardDescription>Oylik buyurtmalar statistikasi</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex items-end justify-between h-48 gap-2">
              {monthlyData.map((month) => (
                <div key={month.month} className="flex-1 flex flex-col items-center">
                  <div
                    className="w-full bg-gradient-to-t from-green-500 to-green-400 rounded-t-lg transition-all"
                    style={{ height: `${(month.orders / 50) * 100}%` }}
                  />
                  <div className="mt-2 text-xs font-medium">{month.month}</div>
                  <div className="text-xs text-muted-foreground">{month.orders}</div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        {/* Top Products */}
        <Card>
          <CardHeader>
            <CardTitle>Top mahsulotlar</CardTitle>
            <CardDescription>Eng ko'p sotilgan mahsulotlar</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {topProducts.map((product, idx) => (
                <div key={product.name} className="flex items-center gap-4">
                  <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center text-sm font-bold text-blue-600">
                    {idx + 1}
                  </div>
                  <div className="flex-1">
                    <div className="font-medium">{product.name}</div>
                    <div className="text-sm text-muted-foreground">
                      {product.sold} ta sotildi
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="font-medium">{formatPrice(product.revenue)}</div>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Recent Orders */}
        <Card>
          <CardHeader>
            <CardTitle>Oxirgi buyurtmalar</CardTitle>
            <CardDescription>So'nggi aktivlik</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {recentOrders.map((order) => (
                <div key={order.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div>
                    <div className="font-mono text-sm">{order.id}</div>
                    <div className="text-sm text-muted-foreground">{order.customer}</div>
                  </div>
                  <div className="text-right">
                    <div className="font-medium">{formatPrice(order.amount)}</div>
                    <div className="text-xs text-muted-foreground">{order.date}</div>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Performance Metrics */}
      <Card>
        <CardHeader>
          <CardTitle>Samaradorlik ko'rsatkichlari</CardTitle>
          <CardDescription>Do'kon reytingi va ko'rsatkichlari</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid gap-6 md:grid-cols-4">
            <div className="text-center p-4 bg-gray-50 rounded-lg">
              <div className="text-3xl mb-2">⭐</div>
              <div className="text-2xl font-bold">4.8</div>
              <div className="text-sm text-muted-foreground">O'rtacha reyting</div>
              <div className="text-xs text-muted-foreground">(256 ta baho)</div>
            </div>
            <div className="text-center p-4 bg-gray-50 rounded-lg">
              <div className="text-3xl mb-2">🚚</div>
              <div className="text-2xl font-bold">98%</div>
              <div className="text-sm text-muted-foreground">Yetkazish vaqtida</div>
            </div>
            <div className="text-center p-4 bg-gray-50 rounded-lg">
              <div className="text-3xl mb-2">↩️</div>
              <div className="text-2xl font-bold">2.1%</div>
              <div className="text-sm text-muted-foreground">Qaytarilgan</div>
            </div>
            <div className="text-center p-4 bg-gray-50 rounded-lg">
              <div className="text-3xl mb-2">💬</div>
              <div className="text-2xl font-bold">15 min</div>
              <div className="text-sm text-muted-foreground">O'rtacha javob vaqti</div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
