'use client'

import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'

// Mock data
const banners = [
  {
    id: '1',
    title: 'Yangi yil aksiyasi',
    imageUrl: '/banners/newyear.jpg',
    link: '/promo/newyear',
    position: 'home_top',
    sortOrder: 1,
    isActive: true,
    startDate: '2026-01-01',
    endDate: '2026-01-31',
    clicks: 1234,
    views: 15678,
  },
  {
    id: '2',
    title: 'Elektronika chegirmasi',
    imageUrl: '/banners/electronics.jpg',
    link: '/category/electronics',
    position: 'home_middle',
    sortOrder: 2,
    isActive: true,
    startDate: '2026-01-15',
    endDate: '2026-02-15',
    clicks: 567,
    views: 8934,
  },
  {
    id: '3',
    title: 'Kiyim kolleksiyasi',
    imageUrl: '/banners/fashion.jpg',
    link: '/category/fashion',
    position: 'home_top',
    sortOrder: 3,
    isActive: false,
    startDate: '2026-02-01',
    endDate: '2026-02-28',
    clicks: 0,
    views: 0,
  },
]

const positionLabels: Record<string, string> = {
  home_top: 'Bosh sahifa (yuqori)',
  home_middle: 'Bosh sahifa (o\'rta)',
  home_bottom: 'Bosh sahifa (pastki)',
  category_top: 'Kategoriya sahifasi',
  product_sidebar: 'Mahsulot sahifasi',
}

export default function AdminBannersPage() {
  const [addDialogOpen, setAddDialogOpen] = useState(false)
  const [formData, setFormData] = useState({
    title: '',
    link: '',
    position: '',
    startDate: '',
    endDate: '',
  })

  const handleAdd = () => {
    console.log('Adding banner:', formData)
    setAddDialogOpen(false)
    setFormData({ title: '', link: '', position: '', startDate: '', endDate: '' })
  }

  const getCTR = (clicks: number, views: number) => {
    if (views === 0) return '0%'
    return ((clicks / views) * 100).toFixed(2) + '%'
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Bannerlar</h1>
          <p className="text-muted-foreground">
            Reklama bannerlarini boshqaring
          </p>
        </div>
        <Dialog open={addDialogOpen} onOpenChange={setAddDialogOpen}>
          <DialogTrigger asChild>
            <Button>+ Banner qo'shish</Button>
          </DialogTrigger>
          <DialogContent className="max-w-xl">
            <DialogHeader>
              <DialogTitle>Yangi banner</DialogTitle>
              <DialogDescription>
                Yangi reklama banneri qo'shing
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4">
              <div className="space-y-2">
                <Label>Sarlavha</Label>
                <Input
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  placeholder="Banner sarlavhasi"
                />
              </div>

              <div className="space-y-2">
                <Label>Rasm</Label>
                <div className="border-2 border-dashed rounded-lg p-8 text-center">
                  <div className="text-4xl mb-2">🖼️</div>
                  <p className="text-sm text-muted-foreground mb-2">
                    Rasmni bu yerga tashlang yoki
                  </p>
                  <Button variant="outline" size="sm">Fayl tanlash</Button>
                  <p className="text-xs text-muted-foreground mt-2">
                    Tavsiya: 1200x400 px, max 2MB
                  </p>
                </div>
              </div>

              <div className="space-y-2">
                <Label>Havola (link)</Label>
                <Input
                  value={formData.link}
                  onChange={(e) => setFormData({ ...formData, link: e.target.value })}
                  placeholder="/category/electronics yoki https://..."
                />
              </div>

              <div className="space-y-2">
                <Label>Joylashuv</Label>
                <Select
                  value={formData.position}
                  onValueChange={(value) => setFormData({ ...formData, position: value })}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Joylashuvni tanlang" />
                  </SelectTrigger>
                  <SelectContent>
                    {Object.entries(positionLabels).map(([value, label]) => (
                      <SelectItem key={value} value={value}>
                        {label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>Boshlanish sanasi</Label>
                  <Input
                    type="date"
                    value={formData.startDate}
                    onChange={(e) => setFormData({ ...formData, startDate: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label>Tugash sanasi</Label>
                  <Input
                    type="date"
                    value={formData.endDate}
                    onChange={(e) => setFormData({ ...formData, endDate: e.target.value })}
                  />
                </div>
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setAddDialogOpen(false)}>
                Bekor qilish
              </Button>
              <Button onClick={handleAdd}>Qo'shish</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>

      {/* Stats */}
      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Jami bannerlar</CardTitle>
            <span className="text-2xl">🖼️</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{banners.length}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Faol</CardTitle>
            <span className="text-2xl">✅</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">
              {banners.filter(b => b.isActive).length}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Jami ko'rishlar</CardTitle>
            <span className="text-2xl">👁️</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {banners.reduce((sum, b) => sum + b.views, 0).toLocaleString()}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Jami bosishlar</CardTitle>
            <span className="text-2xl">👆</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {banners.reduce((sum, b) => sum + b.clicks, 0).toLocaleString()}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Banners Grid */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        {banners.map((banner) => (
          <Card key={banner.id} className={!banner.isActive ? 'opacity-60' : ''}>
            <div className="aspect-[3/1] bg-gradient-to-r from-blue-500 to-purple-600 rounded-t-lg flex items-center justify-center">
              <span className="text-white text-4xl">🖼️</span>
            </div>
            <CardHeader className="pb-2">
              <div className="flex items-center justify-between">
                <CardTitle className="text-lg">{banner.title}</CardTitle>
                <Badge className={banner.isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}>
                  {banner.isActive ? 'Faol' : 'Nofaol'}
                </Badge>
              </div>
              <CardDescription>{positionLabels[banner.position]}</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-3 gap-2 text-center text-sm">
                <div>
                  <div className="font-semibold">{banner.views.toLocaleString()}</div>
                  <div className="text-muted-foreground">Ko'rishlar</div>
                </div>
                <div>
                  <div className="font-semibold">{banner.clicks.toLocaleString()}</div>
                  <div className="text-muted-foreground">Bosishlar</div>
                </div>
                <div>
                  <div className="font-semibold">{getCTR(banner.clicks, banner.views)}</div>
                  <div className="text-muted-foreground">CTR</div>
                </div>
              </div>

              <div className="text-sm text-muted-foreground">
                {banner.startDate} - {banner.endDate}
              </div>

              <div className="flex gap-2">
                <Button variant="outline" size="sm" className="flex-1">
                  Tahrirlash
                </Button>
                <Button
                  variant={banner.isActive ? 'destructive' : 'default'}
                  size="sm"
                  className="flex-1"
                >
                  {banner.isActive ? 'O\'chirish' : 'Yoqish'}
                </Button>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  )
}
