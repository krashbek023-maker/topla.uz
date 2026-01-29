'use client'

import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'

// Mock data
const users = [
  {
    id: '1',
    name: 'Abdulloh Karimov',
    email: 'abdulloh@email.com',
    phone: '+998 90 123 45 67',
    role: 'user',
    orders: 12,
    totalSpent: 45600000,
    status: 'active',
    createdAt: '2025-06-15',
    lastActive: '2026-01-28',
  },
  {
    id: '2',
    name: 'Malika Rahimova',
    email: 'malika@email.com',
    phone: '+998 91 234 56 78',
    role: 'user',
    orders: 8,
    totalSpent: 28500000,
    status: 'active',
    createdAt: '2025-08-20',
    lastActive: '2026-01-27',
  },
  {
    id: '3',
    name: 'Jasur Toshmatov',
    email: 'jasur@email.com',
    phone: '+998 93 345 67 89',
    role: 'vendor',
    orders: 0,
    totalSpent: 0,
    status: 'active',
    createdAt: '2025-10-01',
    lastActive: '2026-01-28',
  },
  {
    id: '4',
    name: 'Nodira Aliyeva',
    email: 'nodira@email.com',
    phone: '+998 94 456 78 90',
    role: 'user',
    orders: 3,
    totalSpent: 5200000,
    status: 'blocked',
    createdAt: '2025-12-10',
    lastActive: '2026-01-15',
  },
]

const roleLabels: Record<string, string> = {
  user: 'Foydalanuvchi',
  vendor: 'Vendor',
  admin: 'Admin',
}

export default function AdminUsersPage() {
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedUser, setSelectedUser] = useState<typeof users[0] | null>(null)
  const [blockDialogOpen, setBlockDialogOpen] = useState(false)

  const filteredUsers = users.filter(user => 
    user.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    user.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
    user.phone.includes(searchQuery)
  )

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('uz-UZ').format(price) + ' so\'m'
  }

  const getInitials = (name: string) => {
    return name.split(' ').map(n => n[0]).join('').toUpperCase()
  }

  const stats = {
    total: users.length,
    active: users.filter(u => u.status === 'active').length,
    vendors: users.filter(u => u.role === 'vendor').length,
    blocked: users.filter(u => u.status === 'blocked').length,
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Foydalanuvchilar</h1>
        <p className="text-muted-foreground">
          Platformadagi barcha foydalanuvchilar
        </p>
      </div>

      {/* Stats */}
      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Jami foydalanuvchilar</CardTitle>
            <span className="text-2xl">👥</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.total}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Faol</CardTitle>
            <span className="text-2xl">✅</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{stats.active}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Vendorlar</CardTitle>
            <span className="text-2xl">🏪</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-600">{stats.vendors}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Bloklangan</CardTitle>
            <span className="text-2xl">🚫</span>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">{stats.blocked}</div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Foydalanuvchilar ro'yxati</CardTitle>
              <CardDescription>Foydalanuvchilarni boshqaring</CardDescription>
            </div>
            <Input
              placeholder="Qidirish (ism, email, telefon)..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-72"
            />
          </div>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Foydalanuvchi</TableHead>
                <TableHead>Telefon</TableHead>
                <TableHead>Rol</TableHead>
                <TableHead>Buyurtmalar</TableHead>
                <TableHead>Jami xarid</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Oxirgi faollik</TableHead>
                <TableHead className="text-right">Amallar</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredUsers.map((user) => (
                <TableRow key={user.id}>
                  <TableCell>
                    <div className="flex items-center gap-3">
                      <Avatar>
                        <AvatarImage src={`https://api.dicebear.com/7.x/initials/svg?seed=${user.name}`} />
                        <AvatarFallback>{getInitials(user.name)}</AvatarFallback>
                      </Avatar>
                      <div>
                        <div className="font-medium">{user.name}</div>
                        <div className="text-sm text-muted-foreground">{user.email}</div>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell>{user.phone}</TableCell>
                  <TableCell>
                    <Badge variant={user.role === 'vendor' ? 'default' : 'secondary'}>
                      {roleLabels[user.role]}
                    </Badge>
                  </TableCell>
                  <TableCell>{user.orders}</TableCell>
                  <TableCell className="font-medium">{formatPrice(user.totalSpent)}</TableCell>
                  <TableCell>
                    <Badge className={user.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}>
                      {user.status === 'active' ? 'Faol' : 'Bloklangan'}
                    </Badge>
                  </TableCell>
                  <TableCell className="text-sm">{user.lastActive}</TableCell>
                  <TableCell className="text-right">
                    <div className="flex items-center justify-end gap-2">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setSelectedUser(user)}
                      >
                        Ko'rish
                      </Button>
                      <Button
                        variant={user.status === 'active' ? 'destructive' : 'default'}
                        size="sm"
                        onClick={() => {
                          setSelectedUser(user)
                          setBlockDialogOpen(true)
                        }}
                      >
                        {user.status === 'active' ? 'Bloklash' : 'Blokdan chiqarish'}
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>

          {filteredUsers.length === 0 && (
            <div className="text-center py-12 text-muted-foreground">
              Foydalanuvchilar topilmadi
            </div>
          )}
        </CardContent>
      </Card>

      {/* Block/Unblock Dialog */}
      <Dialog open={blockDialogOpen} onOpenChange={setBlockDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {selectedUser?.status === 'active' ? 'Foydalanuvchini bloklash' : 'Blokdan chiqarish'}
            </DialogTitle>
            <DialogDescription>
              {selectedUser?.status === 'active'
                ? `"${selectedUser?.name}" foydalanuvchisini bloklashni xohlaysizmi?`
                : `"${selectedUser?.name}" foydalanuvchisini blokdan chiqarishni xohlaysizmi?`}
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setBlockDialogOpen(false)}>
              Bekor qilish
            </Button>
            <Button
              variant={selectedUser?.status === 'active' ? 'destructive' : 'default'}
              onClick={() => {
                console.log(selectedUser?.status === 'active' ? 'Blocking' : 'Unblocking', selectedUser?.id)
                setBlockDialogOpen(false)
              }}
            >
              {selectedUser?.status === 'active' ? 'Bloklash' : 'Blokdan chiqarish'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
