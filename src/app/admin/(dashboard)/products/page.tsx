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
const products = [
  {
    id: '1',
    name: 'iPhone 15 Pro Max',
    shop: 'TechZone',
    category: 'Elektronika',
    price: 15900000,
    status: 'pending',
    images: ['/placeholder.jpg'],
    createdAt: '2026-01-28',
  },
  {
    id: '2',
    name: 'Samsung Galaxy S24',
    shop: 'MobileWorld',
    category: 'Elektronika',
    price: 12500000,
    status: 'approved',
    images: ['/placeholder.jpg'],
    createdAt: '2026-01-27',
  },
  {
    id: '3',
    name: 'Nike Air Max',
    shop: 'SportStyle',
    category: 'Kiyim',
    price: 1200000,
    status: 'rejected',
    images: ['/placeholder.jpg'],
    createdAt: '2026-01-26',
  },
  {
    id: '4',
    name: 'MacBook Pro M3',
    shop: 'TechZone',
    category: 'Elektronika',
    price: 32000000,
    status: 'pending',
    images: ['/placeholder.jpg'],
    createdAt: '2026-01-28',
  },
]

const statusColors: Record<string, string> = {
  pending: 'bg-yellow-100 text-yellow-800',
  approved: 'bg-green-100 text-green-800',
  rejected: 'bg-red-100 text-red-800',
}

const statusLabels: Record<string, string> = {
  pending: 'Kutilmoqda',
  approved: 'Tasdiqlangan',
  rejected: 'Rad etilgan',
}

export default function AdminProductsPage() {
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedProduct, setSelectedProduct] = useState<typeof products[0] | null>(null)
  const [rejectDialogOpen, setRejectDialogOpen] = useState(false)
  const [rejectReason, setRejectReason] = useState('')
  const [activeTab, setActiveTab] = useState('pending')

  const filteredProducts = products.filter(product => {
    const matchesSearch = product.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      product.shop.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesTab = activeTab === 'all' || product.status === activeTab
    return matchesSearch && matchesTab
  })

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('uz-UZ').format(price) + ' so\'m'
  }

  const handleApprove = (productId: string) => {
    console.log('Approved:', productId)
    // API call to approve
  }

  const handleReject = () => {
    if (selectedProduct && rejectReason) {
      console.log('Rejected:', selectedProduct.id, rejectReason)
      // API call to reject
      setRejectDialogOpen(false)
      setRejectReason('')
      setSelectedProduct(null)
    }
  }

  const pendingCount = products.filter(p => p.status === 'pending').length

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Mahsulotlar Moderatsiyasi</h1>
          <p className="text-muted-foreground">
            Vendorlar tomonidan qo'shilgan mahsulotlarni tekshiring
          </p>
        </div>
        {pendingCount > 0 && (
          <Badge variant="destructive" className="text-lg px-4 py-2">
            {pendingCount} ta kutilmoqda
          </Badge>
        )}
      </div>

      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Barcha Mahsulotlar</CardTitle>
              <CardDescription>Mahsulotlarni tasdiqlang yoki rad eting</CardDescription>
            </div>
            <Input
              placeholder="Qidirish..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-64"
            />
          </div>
        </CardHeader>
        <CardContent>
          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <TabsList>
              <TabsTrigger value="pending">
                Kutilmoqda
                <Badge variant="secondary" className="ml-2">
                  {products.filter(p => p.status === 'pending').length}
                </Badge>
              </TabsTrigger>
              <TabsTrigger value="approved">Tasdiqlangan</TabsTrigger>
              <TabsTrigger value="rejected">Rad etilgan</TabsTrigger>
              <TabsTrigger value="all">Barchasi</TabsTrigger>
            </TabsList>

            <TabsContent value={activeTab} className="mt-4">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mahsulot</TableHead>
                    <TableHead>Do'kon</TableHead>
                    <TableHead>Kategoriya</TableHead>
                    <TableHead>Narx</TableHead>
                    <TableHead>Sana</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Amallar</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredProducts.map((product) => (
                    <TableRow key={product.id}>
                      <TableCell>
                        <div className="flex items-center gap-3">
                          <div className="w-12 h-12 bg-gray-100 rounded-lg flex items-center justify-center">
                            <span className="text-2xl">📦</span>
                          </div>
                          <span className="font-medium">{product.name}</span>
                        </div>
                      </TableCell>
                      <TableCell>{product.shop}</TableCell>
                      <TableCell>{product.category}</TableCell>
                      <TableCell className="font-medium">{formatPrice(product.price)}</TableCell>
                      <TableCell>{product.createdAt}</TableCell>
                      <TableCell>
                        <Badge className={statusColors[product.status]}>
                          {statusLabels[product.status]}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex items-center justify-end gap-2">
                          <Button variant="outline" size="sm">
                            Ko'rish
                          </Button>
                          {product.status === 'pending' && (
                            <>
                              <Button
                                size="sm"
                                className="bg-green-600 hover:bg-green-700"
                                onClick={() => handleApprove(product.id)}
                              >
                                ✓ Tasdiqlash
                              </Button>
                              <Button
                                variant="destructive"
                                size="sm"
                                onClick={() => {
                                  setSelectedProduct(product)
                                  setRejectDialogOpen(true)
                                }}
                              >
                                ✕ Rad etish
                              </Button>
                            </>
                          )}
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>

              {filteredProducts.length === 0 && (
                <div className="text-center py-12 text-muted-foreground">
                  Mahsulotlar topilmadi
                </div>
              )}
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>

      {/* Reject Dialog */}
      <Dialog open={rejectDialogOpen} onOpenChange={setRejectDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Mahsulotni rad etish</DialogTitle>
            <DialogDescription>
              "{selectedProduct?.name}" mahsulotini rad etish sababini kiriting
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <Select onValueChange={setRejectReason}>
              <SelectTrigger>
                <SelectValue placeholder="Sabab tanlang" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="low_quality">Sifatsiz rasm</SelectItem>
                <SelectItem value="wrong_category">Noto'g'ri kategoriya</SelectItem>
                <SelectItem value="inappropriate">Nomaqbul kontent</SelectItem>
                <SelectItem value="duplicate">Takroriy mahsulot</SelectItem>
                <SelectItem value="price_issue">Narx muammosi</SelectItem>
                <SelectItem value="other">Boshqa</SelectItem>
              </SelectContent>
            </Select>
            <Input
              placeholder="Qo'shimcha izoh (ixtiyoriy)"
            />
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setRejectDialogOpen(false)}>
              Bekor qilish
            </Button>
            <Button variant="destructive" onClick={handleReject} disabled={!rejectReason}>
              Rad etish
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
