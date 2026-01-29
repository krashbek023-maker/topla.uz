'use client'

import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'

// Mock data
const categories = [
  {
    id: '1',
    nameUz: 'Elektronika',
    nameRu: 'Электроника',
    icon: 'cpu',
    parentId: null,
    sortOrder: 1,
    isActive: true,
    productCount: 156,
    subcategories: [
      { id: '1-1', nameUz: 'Smartfonlar', nameRu: 'Смартфоны', productCount: 45 },
      { id: '1-2', nameUz: 'Noutbuklar', nameRu: 'Ноутбуки', productCount: 32 },
      { id: '1-3', nameUz: 'Televizorlar', nameRu: 'Телевизоры', productCount: 28 },
    ],
  },
  {
    id: '2',
    nameUz: 'Kiyim',
    nameRu: 'Одежда',
    icon: 'shirt',
    parentId: null,
    sortOrder: 2,
    isActive: true,
    productCount: 234,
    subcategories: [
      { id: '2-1', nameUz: 'Erkaklar kiyimi', nameRu: 'Мужская одежда', productCount: 89 },
      { id: '2-2', nameUz: 'Ayollar kiyimi', nameRu: 'Женская одежда', productCount: 102 },
      { id: '2-3', nameUz: 'Bolalar kiyimi', nameRu: 'Детская одежда', productCount: 43 },
    ],
  },
  {
    id: '3',
    nameUz: 'Uy-ro\'zg\'or',
    nameRu: 'Для дома',
    icon: 'home',
    parentId: null,
    sortOrder: 3,
    isActive: true,
    productCount: 89,
    subcategories: [
      { id: '3-1', nameUz: 'Oshxona jihozlari', nameRu: 'Кухонная техника', productCount: 34 },
      { id: '3-2', nameUz: 'Mebel', nameRu: 'Мебель', productCount: 55 },
    ],
  },
  {
    id: '4',
    nameUz: 'Sport',
    nameRu: 'Спорт',
    icon: 'dumbbell',
    parentId: null,
    sortOrder: 4,
    isActive: false,
    productCount: 45,
    subcategories: [],
  },
]

const iconOptions = [
  { value: 'cpu', label: '💻 Elektronika' },
  { value: 'shirt', label: '👕 Kiyim' },
  { value: 'home', label: '🏠 Uy' },
  { value: 'dumbbell', label: '🏋️ Sport' },
  { value: 'heart', label: '💄 Go\'zallik' },
  { value: 'baby', label: '👶 Bolalar' },
  { value: 'utensils', label: '🍽️ Oziq-ovqat' },
  { value: 'car', label: '🚗 Avtomobil' },
]

export default function AdminCategoriesPage() {
  const [addDialogOpen, setAddDialogOpen] = useState(false)
  const [editDialogOpen, setEditDialogOpen] = useState(false)
  const [selectedCategory, setSelectedCategory] = useState<typeof categories[0] | null>(null)
  const [expandedCategories, setExpandedCategories] = useState<string[]>([])

  // Form state
  const [formData, setFormData] = useState({
    nameUz: '',
    nameRu: '',
    icon: '',
    parentId: '',
  })

  const toggleExpand = (categoryId: string) => {
    setExpandedCategories(prev =>
      prev.includes(categoryId)
        ? prev.filter(id => id !== categoryId)
        : [...prev, categoryId]
    )
  }

  const handleAdd = () => {
    console.log('Adding category:', formData)
    setAddDialogOpen(false)
    setFormData({ nameUz: '', nameRu: '', icon: '', parentId: '' })
  }

  const handleEdit = () => {
    console.log('Editing category:', selectedCategory?.id, formData)
    setEditDialogOpen(false)
    setSelectedCategory(null)
  }

  const handleToggleActive = (categoryId: string) => {
    console.log('Toggle active:', categoryId)
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Kategoriyalar</h1>
          <p className="text-muted-foreground">
            Mahsulot kategoriyalarini boshqaring
          </p>
        </div>
        <Dialog open={addDialogOpen} onOpenChange={setAddDialogOpen}>
          <DialogTrigger asChild>
            <Button>+ Kategoriya qo'shish</Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Yangi kategoriya</DialogTitle>
              <DialogDescription>
                Yangi kategoriya yoki subcategoriya qo'shing
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>Nomi (O'zbek)</Label>
                  <Input
                    value={formData.nameUz}
                    onChange={(e) => setFormData({ ...formData, nameUz: e.target.value })}
                    placeholder="Elektronika"
                  />
                </div>
                <div className="space-y-2">
                  <Label>Nomi (Rus)</Label>
                  <Input
                    value={formData.nameRu}
                    onChange={(e) => setFormData({ ...formData, nameRu: e.target.value })}
                    placeholder="Электроника"
                  />
                </div>
              </div>
              <div className="space-y-2">
                <Label>Icon</Label>
                <Select
                  value={formData.icon}
                  onValueChange={(value) => setFormData({ ...formData, icon: value })}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Icon tanlang" />
                  </SelectTrigger>
                  <SelectContent>
                    {iconOptions.map((icon) => (
                      <SelectItem key={icon.value} value={icon.value}>
                        {icon.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>Asosiy kategoriya (ixtiyoriy)</Label>
                <Select
                  value={formData.parentId}
                  onValueChange={(value) => setFormData({ ...formData, parentId: value })}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Asosiy kategoriya (subcategoriya uchun)" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="none">Asosiy kategoriya</SelectItem>
                    {categories.map((cat) => (
                      <SelectItem key={cat.id} value={cat.id}>
                        {cat.nameUz}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
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

      <Card>
        <CardHeader>
          <CardTitle>Kategoriyalar ro'yxati</CardTitle>
          <CardDescription>
            Jami {categories.length} ta asosiy kategoriya
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-12"></TableHead>
                <TableHead>Nomi (UZ)</TableHead>
                <TableHead>Nomi (RU)</TableHead>
                <TableHead>Subcategoriyalar</TableHead>
                <TableHead>Mahsulotlar</TableHead>
                <TableHead>Tartib</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="text-right">Amallar</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {categories.map((category) => (
                <>
                  <TableRow key={category.id} className="bg-muted/30">
                    <TableCell>
                      {category.subcategories.length > 0 && (
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => toggleExpand(category.id)}
                        >
                          {expandedCategories.includes(category.id) ? '▼' : '▶'}
                        </Button>
                      )}
                    </TableCell>
                    <TableCell className="font-medium">
                      <div className="flex items-center gap-2">
                        <span className="text-xl">
                          {iconOptions.find(i => i.value === category.icon)?.label.split(' ')[0] || '📦'}
                        </span>
                        {category.nameUz}
                      </div>
                    </TableCell>
                    <TableCell>{category.nameRu}</TableCell>
                    <TableCell>
                      <Badge variant="secondary">
                        {category.subcategories.length} ta
                      </Badge>
                    </TableCell>
                    <TableCell>{category.productCount}</TableCell>
                    <TableCell>{category.sortOrder}</TableCell>
                    <TableCell>
                      <Badge className={category.isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}>
                        {category.isActive ? 'Faol' : 'Nofaol'}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex items-center justify-end gap-2">
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => {
                            setSelectedCategory(category)
                            setFormData({
                              nameUz: category.nameUz,
                              nameRu: category.nameRu,
                              icon: category.icon,
                              parentId: '',
                            })
                            setEditDialogOpen(true)
                          }}
                        >
                          Tahrirlash
                        </Button>
                        <Button
                          variant={category.isActive ? 'destructive' : 'default'}
                          size="sm"
                          onClick={() => handleToggleActive(category.id)}
                        >
                          {category.isActive ? 'O\'chirish' : 'Yoqish'}
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                  {/* Subcategories */}
                  {expandedCategories.includes(category.id) &&
                    category.subcategories.map((sub) => (
                      <TableRow key={sub.id} className="bg-white">
                        <TableCell></TableCell>
                        <TableCell className="pl-12">
                          ↳ {sub.nameUz}
                        </TableCell>
                        <TableCell>{sub.nameRu}</TableCell>
                        <TableCell>-</TableCell>
                        <TableCell>{sub.productCount}</TableCell>
                        <TableCell>-</TableCell>
                        <TableCell>
                          <Badge className="bg-green-100 text-green-800">Faol</Badge>
                        </TableCell>
                        <TableCell className="text-right">
                          <Button variant="outline" size="sm">
                            Tahrirlash
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))}
                </>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Edit Dialog */}
      <Dialog open={editDialogOpen} onOpenChange={setEditDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Kategoriyani tahrirlash</DialogTitle>
            <DialogDescription>
              "{selectedCategory?.nameUz}" kategoriyasini tahrirlang
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Nomi (O'zbek)</Label>
                <Input
                  value={formData.nameUz}
                  onChange={(e) => setFormData({ ...formData, nameUz: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <Label>Nomi (Rus)</Label>
                <Input
                  value={formData.nameRu}
                  onChange={(e) => setFormData({ ...formData, nameRu: e.target.value })}
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label>Icon</Label>
              <Select
                value={formData.icon}
                onValueChange={(value) => setFormData({ ...formData, icon: value })}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {iconOptions.map((icon) => (
                    <SelectItem key={icon.value} value={icon.value}>
                      {icon.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditDialogOpen(false)}>
              Bekor qilish
            </Button>
            <Button onClick={handleEdit}>Saqlash</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
