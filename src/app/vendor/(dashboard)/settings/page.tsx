'use client'

import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Badge } from '@/components/ui/badge'

export default function VendorSettingsPage() {
  const [shopData, setShopData] = useState({
    name: 'TechZone',
    description: 'Eng yaxshi elektronika do\'koni. Original gadgetlar va qurilmalar.',
    phone: '+998 90 123 45 67',
    email: 'techzone@email.com',
    address: 'Toshkent, Chilonzor tumani, 12-mavze',
    workingHours: '09:00 - 21:00',
    logo: null,
  })

  const [bankData, setBankData] = useState({
    cardNumber: '8600 1234 5678 9012',
    cardHolder: 'JASUR TOSHMATOV',
    bankName: 'Kapitalbank',
  })

  const [notificationSettings, setNotificationSettings] = useState({
    newOrder: true,
    orderStatus: true,
    payout: true,
    promotion: false,
  })

  const handleSaveShop = () => {
    console.log('Saving shop data:', shopData)
  }

  const handleSaveBank = () => {
    console.log('Saving bank data:', bankData)
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Sozlamalar</h1>
        <p className="text-muted-foreground">
          Do'kon va hisob sozlamalarini boshqaring
        </p>
      </div>

      <Tabs defaultValue="shop" className="space-y-4">
        <TabsList>
          <TabsTrigger value="shop">Do'kon ma'lumotlari</TabsTrigger>
          <TabsTrigger value="bank">Bank ma'lumotlari</TabsTrigger>
          <TabsTrigger value="notifications">Bildirishnomalar</TabsTrigger>
          <TabsTrigger value="security">Xavfsizlik</TabsTrigger>
        </TabsList>

        {/* Shop Settings */}
        <TabsContent value="shop">
          <Card>
            <CardHeader>
              <CardTitle>Do'kon ma'lumotlari</CardTitle>
              <CardDescription>Do'kon profili va aloqa ma'lumotlari</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="flex items-start gap-6">
                <div className="w-24 h-24 bg-gray-100 rounded-xl flex items-center justify-center">
                  <span className="text-4xl">🏪</span>
                </div>
                <div className="space-y-2">
                  <Label>Do'kon logosi</Label>
                  <div className="flex gap-2">
                    <Button variant="outline" size="sm">Rasm yuklash</Button>
                    <Button variant="ghost" size="sm">O'chirish</Button>
                  </div>
                  <p className="text-xs text-muted-foreground">
                    Tavsiya: 200x200 px, PNG yoki JPG
                  </p>
                </div>
              </div>

              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label>Do'kon nomi</Label>
                  <Input
                    value={shopData.name}
                    onChange={(e) => setShopData({ ...shopData, name: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label>Telefon raqam</Label>
                  <Input
                    value={shopData.phone}
                    onChange={(e) => setShopData({ ...shopData, phone: e.target.value })}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label>Tavsif</Label>
                <textarea
                  className="w-full min-h-[100px] px-3 py-2 border rounded-md"
                  value={shopData.description}
                  onChange={(e) => setShopData({ ...shopData, description: e.target.value })}
                />
              </div>

              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label>Email</Label>
                  <Input
                    type="email"
                    value={shopData.email}
                    onChange={(e) => setShopData({ ...shopData, email: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label>Ish vaqti</Label>
                  <Input
                    value={shopData.workingHours}
                    onChange={(e) => setShopData({ ...shopData, workingHours: e.target.value })}
                    placeholder="09:00 - 21:00"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label>Manzil</Label>
                <Input
                  value={shopData.address}
                  onChange={(e) => setShopData({ ...shopData, address: e.target.value })}
                />
              </div>

              <Button onClick={handleSaveShop}>Saqlash</Button>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Bank Settings */}
        <TabsContent value="bank">
          <Card>
            <CardHeader>
              <CardTitle>Bank ma'lumotlari</CardTitle>
              <CardDescription>Pul yechish uchun karta ma'lumotlari</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="p-6 bg-gradient-to-r from-blue-600 to-blue-800 rounded-xl text-white max-w-md">
                <div className="flex justify-between items-start mb-8">
                  <span className="text-lg font-semibold">{bankData.bankName}</span>
                  <span className="text-2xl">💳</span>
                </div>
                <div className="text-xl tracking-wider mb-4">
                  {bankData.cardNumber}
                </div>
                <div className="text-sm opacity-80">
                  {bankData.cardHolder}
                </div>
              </div>

              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label>Karta raqami</Label>
                  <Input
                    value={bankData.cardNumber}
                    onChange={(e) => setBankData({ ...bankData, cardNumber: e.target.value })}
                    placeholder="8600 **** **** ****"
                  />
                </div>
                <div className="space-y-2">
                  <Label>Karta egasi</Label>
                  <Input
                    value={bankData.cardHolder}
                    onChange={(e) => setBankData({ ...bankData, cardHolder: e.target.value })}
                    placeholder="ISM FAMILIYA"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label>Bank nomi</Label>
                <Input
                  value={bankData.bankName}
                  onChange={(e) => setBankData({ ...bankData, bankName: e.target.value })}
                />
              </div>

              <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
                <p className="text-sm text-yellow-800">
                  ⚠️ Bank ma'lumotlarini o'zgartirsangiz, yangi karta tasdiqlash jarayonidan o'tadi (1-2 ish kuni)
                </p>
              </div>

              <Button onClick={handleSaveBank}>Saqlash</Button>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Notification Settings */}
        <TabsContent value="notifications">
          <Card>
            <CardHeader>
              <CardTitle>Bildirishnoma sozlamalari</CardTitle>
              <CardDescription>Qanday xabarlarni olishni tanlang</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between p-4 border rounded-lg">
                <div>
                  <div className="font-medium">Yangi buyurtma</div>
                  <div className="text-sm text-muted-foreground">
                    Yangi buyurtma kelganda xabar
                  </div>
                </div>
                <Button
                  variant={notificationSettings.newOrder ? 'default' : 'outline'}
                  onClick={() => setNotificationSettings({
                    ...notificationSettings,
                    newOrder: !notificationSettings.newOrder
                  })}
                >
                  {notificationSettings.newOrder ? '✓ Yoqilgan' : 'O\'chirilgan'}
                </Button>
              </div>

              <div className="flex items-center justify-between p-4 border rounded-lg">
                <div>
                  <div className="font-medium">Buyurtma statusi</div>
                  <div className="text-sm text-muted-foreground">
                    Buyurtma statusi o'zgarganda xabar
                  </div>
                </div>
                <Button
                  variant={notificationSettings.orderStatus ? 'default' : 'outline'}
                  onClick={() => setNotificationSettings({
                    ...notificationSettings,
                    orderStatus: !notificationSettings.orderStatus
                  })}
                >
                  {notificationSettings.orderStatus ? '✓ Yoqilgan' : 'O\'chirilgan'}
                </Button>
              </div>

              <div className="flex items-center justify-between p-4 border rounded-lg">
                <div>
                  <div className="font-medium">To'lov xabari</div>
                  <div className="text-sm text-muted-foreground">
                    Pul yechish tasdiqlanganda xabar
                  </div>
                </div>
                <Button
                  variant={notificationSettings.payout ? 'default' : 'outline'}
                  onClick={() => setNotificationSettings({
                    ...notificationSettings,
                    payout: !notificationSettings.payout
                  })}
                >
                  {notificationSettings.payout ? '✓ Yoqilgan' : 'O\'chirilgan'}
                </Button>
              </div>

              <div className="flex items-center justify-between p-4 border rounded-lg">
                <div>
                  <div className="font-medium">Aksiya va yangiliklar</div>
                  <div className="text-sm text-muted-foreground">
                    Platforma aksiyalari haqida xabar
                  </div>
                </div>
                <Button
                  variant={notificationSettings.promotion ? 'default' : 'outline'}
                  onClick={() => setNotificationSettings({
                    ...notificationSettings,
                    promotion: !notificationSettings.promotion
                  })}
                >
                  {notificationSettings.promotion ? '✓ Yoqilgan' : 'O\'chirilgan'}
                </Button>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Security Settings */}
        <TabsContent value="security">
          <Card>
            <CardHeader>
              <CardTitle>Xavfsizlik</CardTitle>
              <CardDescription>Hisob xavfsizligi sozlamalari</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="space-y-4">
                <div className="flex items-center justify-between p-4 border rounded-lg">
                  <div>
                    <div className="font-medium">Parolni o'zgartirish</div>
                    <div className="text-sm text-muted-foreground">
                      Oxirgi o'zgarish: 30 kun oldin
                    </div>
                  </div>
                  <Button variant="outline">O'zgartirish</Button>
                </div>

                <div className="flex items-center justify-between p-4 border rounded-lg">
                  <div>
                    <div className="font-medium">Ikki bosqichli autentifikatsiya</div>
                    <div className="text-sm text-muted-foreground">
                      SMS orqali qo'shimcha himoya
                    </div>
                  </div>
                  <Badge className="bg-green-100 text-green-800">Yoqilgan</Badge>
                </div>

                <div className="flex items-center justify-between p-4 border rounded-lg">
                  <div>
                    <div className="font-medium">Aktiv sessiyalar</div>
                    <div className="text-sm text-muted-foreground">
                      3 ta qurilmada kirish mavjud
                    </div>
                  </div>
                  <Button variant="outline">Boshqarish</Button>
                </div>
              </div>

              <div className="border-t pt-6">
                <h4 className="font-medium text-red-600 mb-4">Xavfli zona</h4>
                <div className="flex items-center justify-between p-4 border border-red-200 rounded-lg bg-red-50">
                  <div>
                    <div className="font-medium text-red-800">Do'konni o'chirish</div>
                    <div className="text-sm text-red-600">
                      Bu amalni qaytarib bo'lmaydi
                    </div>
                  </div>
                  <Button variant="destructive">O'chirish</Button>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}
