'use client'

import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'

// Mock data
const orders = [
  {
    id: 'ORD-001',
    customer: 'Abdulloh Karimov',
    phone: '+998 90 123 45 67',
    items: [
      { name: 'iPhone 15 Pro Max', quantity: 1, price: 15900000 },
      { name: 'AirPods Pro', quantity: 1, price: 2600000 },
    ],
    total: 18500000,
    status: 'pending',
    paymentMethod: 'Naqd',
    address: 'Toshkent, Yunusobod tumani, 12-uy',
    createdAt: '2026-01-28 14:30',
  },
  {
    id: 'ORD-002',
    customer: 'Malika Rahimova',
    phone: '+998 91 234 56 78',
    items: [
      { name: 'Samsung Galaxy S24', quantity: 1, price: 12500000 },
    ],
    total: 12500000,
    status: 'processing',
    paymentMethod: 'Karta',
    address: 'Toshkent, Mirzo Ulug\'bek tumani, 5-dom',
    createdAt: '2026-01-28 12:15',
  },
  {
    id: 'ORD-003',
    customer: 'Jasur Toshmatov',
    phone: '+998 93 345 67 89',
    items: [
      { name: 'MacBook Pro M3', quantity: 1, price: 32000000 },
    ],
    total: 32000000,
    status: 'shipped',
    paymentMethod: 'Naqd',
    address: 'Samarqand, Registon ko\'chasi, 45',
    createdAt: '2026-01-27 10:00',
  },
  {
    id: 'ORD-004',
    customer: 'Nodira Aliyeva',
    phone: '+998 94 456 78 90',
    items: [
      { name: 'iPad Pro 12.9', quantity: 1, price: 18000000 },
    ],
    total: 18000000,
    status: 'delivered',
    paymentMethod: 'Karta',
    address: 'Buxoro, Mustaqillik ko\'chasi, 78',
    createdAt: '2026-01-26 16:45',
  },
]

const statusConfig: Record<string, { color: string; label: string; nextStatus?: string; nextLabel?: string }> = {
  pending: { color: 'bg-yellow-100 text-yellow-800', label: 'Yangi', nextStatus: 'processing', nextLabel: 'Qabul qilish' },
  processing: { color: 'bg-blue-100 text-blue-800', label: 'Tayyorlanmoqda', nextStatus: 'shipped', nextLabel: 'Jo\'natish' },
  shipped: { color: 'bg-purple-100 text-purple-800', label: 'Yo\'lda', nextStatus: 'delivered', nextLabel: 'Yetkazildi' },
  delivered: { color: 'bg-green-100 text-green-800', label: 'Yetkazildi' },
  cancelled: { color: 'bg-red-100 text-red-800', label: 'Bekor qilindi' },
}

export default function VendorOrdersPage() {
  const [searchQuery, setSearchQuery] = useState('')
  const [activeTab, setActiveTab] = useState('all')
  const [selectedOrder, setSelectedOrder] = useState<typeof orders[0] | null>(null)
  const [cancelDialogOpen, setCancelDialogOpen] = useState(false)

  const filteredOrders = orders.filter(order => {
    const matchesSearch = order.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
      order.customer.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesTab = activeTab === 'all' || order.status === activeTab
    return matchesSearch && matchesTab
  })

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('uz-UZ').format(price) + ' so\'m'
  }

  const handleUpdateStatus = (orderId: string, newStatus: string) => {
    console.log('Updating order status:', orderId, newStatus)
    // API call
  }

  const stats = {
    pending: orders.filter(o => o.status === 'pending').length,
    processing: orders.filter(o => o.status === 'processing').length,
    shipped: orders.filter(o => o.status === 'shipped').length,
    todayRevenue: orders.filter(o => o.status === 'delivered').reduce((sum, o) => sum + o.total, 0),
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Buyurtmalar</h1>
        <p className="text-muted-foreground">
          Do'koningizga kelgan buyurtmalarni boshqaring
        </p>
      </div>

      {/* Stats */}
      <div className="grid gap-4 md:grid-cols-4">
        <Card className="border-yellow-200 bg-yellow-50">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Yangi</CardTitle>
            <span className="text-2xl">🔔</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-yellow-600">{stats.pending}</div>
            <p className="text-xs text-muted-foreground">Qabul qilish kerak</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Tayyorlanmoqda</CardTitle>
            <span className="text-2xl">📦</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-600">{stats.processing}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Yo'lda</CardTitle>
            <span className="text-2xl">🚚</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-purple-600">{stats.shipped}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Bugungi daromad</CardTitle>
            <span className="text-2xl">💰</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{formatPrice(stats.todayRevenue)}</div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Buyurtmalar ro'yxati</CardTitle>
              <CardDescription>Buyurtma statusini o'zgartiring</CardDescription>
            </div>
            <Input
              placeholder="Qidirish (ID, mijoz)..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-64"
            />
          </div>
        </CardHeader>
        <CardContent>
          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <TabsList>
              <TabsTrigger value="all">Barchasi</TabsTrigger>
              <TabsTrigger value="pending" className="relative">
                Yangi
                {stats.pending > 0 && (
                  <span className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 text-white text-xs rounded-full flex items-center justify-center">
                    {stats.pending}
                  </span>
                )}
              </TabsTrigger>
              <TabsTrigger value="processing">Tayyorlanmoqda</TabsTrigger>
              <TabsTrigger value="shipped">Yo'lda</TabsTrigger>
              <TabsTrigger value="delivered">Yetkazildi</TabsTrigger>
            </TabsList>

            <TabsContent value={activeTab} className="mt-4">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Buyurtma</TableHead>
                    <TableHead>Mijoz</TableHead>
                    <TableHead>Mahsulotlar</TableHead>
                    <TableHead>Summa</TableHead>
                    <TableHead>To'lov</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Amallar</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredOrders.map((order) => (
                    <TableRow key={order.id} className={order.status === 'pending' ? 'bg-yellow-50' : ''}>
                      <TableCell>
                        <div>
                          <div className="font-mono font-medium">{order.id}</div>
                          <div className="text-xs text-muted-foreground">{order.createdAt}</div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div>
                          <div className="font-medium">{order.customer}</div>
                          <div className="text-sm text-muted-foreground">{order.phone}</div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="text-sm">
                          {order.items.map((item, idx) => (
                            <div key={idx}>{item.quantity}x {item.name}</div>
                          ))}
                        </div>
                      </TableCell>
                      <TableCell className="font-medium">{formatPrice(order.total)}</TableCell>
                      <TableCell>
                        <Badge variant="outline">{order.paymentMethod}</Badge>
                      </TableCell>
                      <TableCell>
                        <Badge className={statusConfig[order.status].color}>
                          {statusConfig[order.status].label}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex items-center justify-end gap-2">
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => setSelectedOrder(order)}
                          >
                            Ko'rish
                          </Button>
                          {statusConfig[order.status].nextStatus && (
                            <Button
                              size="sm"
                              onClick={() => handleUpdateStatus(order.id, statusConfig[order.status].nextStatus!)}
                            >
                              {statusConfig[order.status].nextLabel}
                            </Button>
                          )}
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>

              {filteredOrders.length === 0 && (
                <div className="text-center py-12 text-muted-foreground">
                  Buyurtmalar topilmadi
                </div>
              )}
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>

      {/* Order Detail Dialog */}
      <Dialog open={!!selectedOrder} onOpenChange={() => setSelectedOrder(null)}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>Buyurtma: {selectedOrder?.id}</DialogTitle>
            <DialogDescription>
              {selectedOrder?.createdAt}
            </DialogDescription>
          </DialogHeader>
          {selectedOrder && (
            <div className="space-y-6">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <h4 className="font-semibold mb-2">Mijoz ma'lumotlari</h4>
                  <div className="space-y-1 text-sm">
                    <p><span className="text-muted-foreground">Ism:</span> {selectedOrder.customer}</p>
                    <p><span className="text-muted-foreground">Telefon:</span> {selectedOrder.phone}</p>
                    <p><span className="text-muted-foreground">Manzil:</span> {selectedOrder.address}</p>
                  </div>
                </div>
                <div>
                  <h4 className="font-semibold mb-2">Buyurtma statusi</h4>
                  <Badge className={statusConfig[selectedOrder.status].color + ' text-base px-3 py-1'}>
                    {statusConfig[selectedOrder.status].label}
                  </Badge>
                </div>
              </div>

              <div>
                <h4 className="font-semibold mb-2">Mahsulotlar</h4>
                <div className="border rounded-lg divide-y">
                  {selectedOrder.items.map((item, idx) => (
                    <div key={idx} className="flex items-center justify-between p-3">
                      <div>
                        <span className="font-medium">{item.name}</span>
                        <span className="text-muted-foreground ml-2">x{item.quantity}</span>
                      </div>
                      <span>{formatPrice(item.price)}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="border-t pt-4">
                <div className="flex items-center justify-between">
                  <span className="text-lg font-semibold">Jami:</span>
                  <span className="text-2xl font-bold text-green-600">
                    {formatPrice(selectedOrder.total)}
                  </span>
                </div>
              </div>

              <div className="flex gap-2">
                {statusConfig[selectedOrder.status].nextStatus && (
                  <Button
                    className="flex-1"
                    onClick={() => {
                      handleUpdateStatus(selectedOrder.id, statusConfig[selectedOrder.status].nextStatus!)
                      setSelectedOrder(null)
                    }}
                  >
                    {statusConfig[selectedOrder.status].nextLabel}
                  </Button>
                )}
                {selectedOrder.status === 'pending' && (
                  <Button
                    variant="destructive"
                    className="flex-1"
                    onClick={() => {
                      setSelectedOrder(null)
                      setCancelDialogOpen(true)
                    }}
                  >
                    Bekor qilish
                  </Button>
                )}
                <Button variant="outline" className="flex-1">
                  Chop etish
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  )
}
