'use client'

import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from '@/components/ui/dialog'

// Mock data
const orders = [
  {
    id: 'ORD-001',
    customer: 'Abdulloh Karimov',
    phone: '+998 90 123 45 67',
    shop: 'TechZone',
    items: 2,
    total: 18500000,
    status: 'pending',
    paymentMethod: 'Naqd',
    address: 'Toshkent, Yunusobod tumani',
    createdAt: '2026-01-28 14:30',
  },
  {
    id: 'ORD-002',
    customer: 'Malika Rahimova',
    phone: '+998 91 234 56 78',
    shop: 'MobileWorld',
    items: 1,
    total: 12500000,
    status: 'processing',
    paymentMethod: 'Karta',
    address: 'Toshkent, Mirzo Ulug\'bek tumani',
    createdAt: '2026-01-28 12:15',
  },
  {
    id: 'ORD-003',
    customer: 'Jasur Toshmatov',
    phone: '+998 93 345 67 89',
    shop: 'SportStyle',
    items: 3,
    total: 2400000,
    status: 'delivered',
    paymentMethod: 'Naqd',
    address: 'Samarqand, Registon ko\'chasi',
    createdAt: '2026-01-27 10:00',
  },
  {
    id: 'ORD-004',
    customer: 'Nodira Aliyeva',
    phone: '+998 94 456 78 90',
    shop: 'TechZone',
    items: 1,
    total: 32000000,
    status: 'cancelled',
    paymentMethod: 'Karta',
    address: 'Buxoro, Mustaqillik ko\'chasi',
    createdAt: '2026-01-26 16:45',
  },
]

const statusConfig: Record<string, { color: string; label: string }> = {
  pending: { color: 'bg-yellow-100 text-yellow-800', label: 'Kutilmoqda' },
  processing: { color: 'bg-blue-100 text-blue-800', label: 'Jarayonda' },
  shipped: { color: 'bg-purple-100 text-purple-800', label: 'Yo\'lda' },
  delivered: { color: 'bg-green-100 text-green-800', label: 'Yetkazildi' },
  cancelled: { color: 'bg-red-100 text-red-800', label: 'Bekor qilindi' },
}

export default function AdminOrdersPage() {
  const [searchQuery, setSearchQuery] = useState('')
  const [activeTab, setActiveTab] = useState('all')
  const [selectedOrder, setSelectedOrder] = useState<typeof orders[0] | null>(null)

  const filteredOrders = orders.filter(order => {
    const matchesSearch = order.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
      order.customer.toLowerCase().includes(searchQuery.toLowerCase()) ||
      order.shop.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesTab = activeTab === 'all' || order.status === activeTab
    return matchesSearch && matchesTab
  })

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('uz-UZ').format(price) + ' so\'m'
  }

  const stats = {
    total: orders.length,
    pending: orders.filter(o => o.status === 'pending').length,
    processing: orders.filter(o => o.status === 'processing').length,
    delivered: orders.filter(o => o.status === 'delivered').length,
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Buyurtmalar</h1>
        <p className="text-muted-foreground">
          Barcha buyurtmalarni boshqaring
        </p>
      </div>

      {/* Stats */}
      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Jami buyurtmalar</CardTitle>
            <span className="text-2xl">📦</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.total}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Kutilmoqda</CardTitle>
            <span className="text-2xl">⏳</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-yellow-600">{stats.pending}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Jarayonda</CardTitle>
            <span className="text-2xl">🔄</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-600">{stats.processing}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Yetkazildi</CardTitle>
            <span className="text-2xl">✅</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{stats.delivered}</div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Buyurtmalar ro'yxati</CardTitle>
              <CardDescription>Buyurtmalar statusini kuzating</CardDescription>
            </div>
            <Input
              placeholder="Qidirish (ID, mijoz, do'kon)..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-72"
            />
          </div>
        </CardHeader>
        <CardContent>
          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <TabsList>
              <TabsTrigger value="all">Barchasi</TabsTrigger>
              <TabsTrigger value="pending">Kutilmoqda</TabsTrigger>
              <TabsTrigger value="processing">Jarayonda</TabsTrigger>
              <TabsTrigger value="shipped">Yo'lda</TabsTrigger>
              <TabsTrigger value="delivered">Yetkazildi</TabsTrigger>
              <TabsTrigger value="cancelled">Bekor</TabsTrigger>
            </TabsList>

            <TabsContent value={activeTab} className="mt-4">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Buyurtma ID</TableHead>
                    <TableHead>Mijoz</TableHead>
                    <TableHead>Do'kon</TableHead>
                    <TableHead>Mahsulotlar</TableHead>
                    <TableHead>Summa</TableHead>
                    <TableHead>To'lov</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Sana</TableHead>
                    <TableHead className="text-right">Amallar</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredOrders.map((order) => (
                    <TableRow key={order.id}>
                      <TableCell className="font-mono font-medium">{order.id}</TableCell>
                      <TableCell>
                        <div>
                          <div className="font-medium">{order.customer}</div>
                          <div className="text-sm text-muted-foreground">{order.phone}</div>
                        </div>
                      </TableCell>
                      <TableCell>{order.shop}</TableCell>
                      <TableCell>{order.items} ta</TableCell>
                      <TableCell className="font-medium">{formatPrice(order.total)}</TableCell>
                      <TableCell>
                        <Badge variant="outline">{order.paymentMethod}</Badge>
                      </TableCell>
                      <TableCell>
                        <Badge className={statusConfig[order.status].color}>
                          {statusConfig[order.status].label}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-sm">{order.createdAt}</TableCell>
                      <TableCell className="text-right">
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => setSelectedOrder(order)}
                        >
                          Batafsil
                        </Button>
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
              {selectedOrder?.createdAt} da yaratilgan
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
                  <h4 className="font-semibold mb-2">Buyurtma ma'lumotlari</h4>
                  <div className="space-y-1 text-sm">
                    <p><span className="text-muted-foreground">Do'kon:</span> {selectedOrder.shop}</p>
                    <p><span className="text-muted-foreground">Mahsulotlar:</span> {selectedOrder.items} ta</p>
                    <p><span className="text-muted-foreground">To'lov:</span> {selectedOrder.paymentMethod}</p>
                  </div>
                </div>
              </div>

              <div className="border-t pt-4">
                <div className="flex items-center justify-between">
                  <span className="text-lg font-semibold">Jami summa:</span>
                  <span className="text-2xl font-bold text-green-600">
                    {formatPrice(selectedOrder.total)}
                  </span>
                </div>
              </div>

              <div className="flex gap-2">
                <Button variant="outline" className="flex-1">
                  Chop etish
                </Button>
                <Button variant="outline" className="flex-1">
                  Mijozga yozish
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  )
}
