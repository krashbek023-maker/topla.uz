import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  ShoppingBag,
  Store,
  TrendingUp,
  Shield,
  Truck,
  Users,
  ArrowRight,
  CheckCircle2,
  Star,
  Package,
  Headphones,
} from "lucide-react";

export default function HomePage() {
  return (
    <div className="min-h-screen bg-background overflow-x-hidden">
      {/* Header */}
      <header className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div className="container flex h-14 sm:h-16 items-center justify-between px-4 sm:px-6">
          <Link href="/" className="flex items-center gap-2">
            <div className="h-7 w-7 sm:h-8 sm:w-8 rounded-lg bg-primary flex items-center justify-center">
              <ShoppingBag className="h-4 w-4 sm:h-5 sm:w-5 text-primary-foreground" />
            </div>
            <span className="text-lg sm:text-xl font-bold">TOPLA.UZ</span>
          </Link>

          <nav className="hidden md:flex items-center gap-6">
            <Link href="#features" className="text-sm font-medium hover:text-primary">
              Imkoniyatlar
            </Link>
            <Link href="#how-it-works" className="text-sm font-medium hover:text-primary">
              Qanday ishlaydi
            </Link>
            <Link href="#testimonials" className="text-sm font-medium hover:text-primary">
              Fikrlar
            </Link>
            <Link href="/contact" className="text-sm font-medium hover:text-primary">
              Aloqa
            </Link>
          </nav>

          <div className="flex items-center gap-2 sm:gap-3">
            <Button variant="ghost" size="sm" className="text-xs sm:text-sm px-2 sm:px-4" asChild>
              <Link href="/vendor/login">Kirish</Link>
            </Button>
            <Button size="sm" className="text-xs sm:text-sm px-2 sm:px-4" asChild>
              <Link href="/vendor/register">Sotuvchi bo'lish</Link>
            </Button>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="container py-12 sm:py-16 md:py-24 lg:py-32 px-4 sm:px-6">
        <div className="grid lg:grid-cols-2 gap-8 lg:gap-12 items-center">
          <div className="space-y-6 sm:space-y-8">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 text-primary text-xs sm:text-sm">
              <Star className="h-3 w-3 sm:h-4 sm:w-4" />
              O'zbekistonning #1 marketplace platformasi
            </div>
            <h1 className="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight leading-tight">
              Biznesingizni
              <span className="text-primary"> onlayn </span>
              olamga olib chiqing
            </h1>
            <p className="text-base sm:text-lg md:text-xl text-muted-foreground max-w-lg">
              TOPLA.UZ platformasida do'kon oching va millionlab mijozlarga mahsulotlaringizni
              yetkazing. Bepul ro'yxatdan o'ting!
            </p>
            <div className="flex flex-col sm:flex-row gap-3 sm:gap-4">
              <Button size="lg" className="gap-2 w-full sm:w-auto" asChild>
                <Link href="/vendor/register">
                  Bepul boshlash
                  <ArrowRight className="h-4 w-4" />
                </Link>
              </Button>
              <Button size="lg" variant="outline" className="w-full sm:w-auto" asChild>
                <Link href="#how-it-works">Batafsil ma'lumot</Link>
              </Button>
            </div>
            <div className="flex items-center justify-between sm:justify-start gap-4 sm:gap-8 pt-4">
              <div className="text-center sm:text-left">
                <div className="text-xl sm:text-2xl md:text-3xl font-bold">1,500+</div>
                <div className="text-xs sm:text-sm text-muted-foreground">Faol do'konlar</div>
              </div>
              <div className="text-center sm:text-left">
                <div className="text-xl sm:text-2xl md:text-3xl font-bold">50,000+</div>
                <div className="text-xs sm:text-sm text-muted-foreground">Mahsulotlar</div>
              </div>
              <div className="text-center sm:text-left">
                <div className="text-xl sm:text-2xl md:text-3xl font-bold">100,000+</div>
                <div className="text-xs sm:text-sm text-muted-foreground">Mijozlar</div>
              </div>
            </div>
          </div>
          <div className="relative mt-8 lg:mt-0">
            <div className="aspect-square max-w-sm mx-auto lg:max-w-none rounded-3xl bg-gradient-to-br from-primary/20 to-primary/5 flex items-center justify-center">
              <Store className="h-24 w-24 sm:h-32 sm:w-32 md:h-48 md:w-48 text-primary/40" />
            </div>
            <div className="absolute bottom-0 left-0 sm:-bottom-6 sm:-left-6 bg-card p-3 sm:p-4 rounded-xl shadow-lg border">
              <div className="flex items-center gap-2 sm:gap-3">
                <div className="h-8 w-8 sm:h-10 sm:w-10 rounded-full bg-green-500/20 flex items-center justify-center">
                  <TrendingUp className="h-4 w-4 sm:h-5 sm:w-5 text-green-500" />
                </div>
                <div>
                  <div className="text-sm sm:text-base font-semibold">+156%</div>
                  <div className="text-[10px] sm:text-xs text-muted-foreground">Oylik o'sish</div>
                </div>
              </div>
            </div>
            <div className="absolute top-0 right-0 sm:-top-6 sm:-right-6 bg-card p-3 sm:p-4 rounded-xl shadow-lg border">
              <div className="flex items-center gap-2 sm:gap-3">
                <div className="h-8 w-8 sm:h-10 sm:w-10 rounded-full bg-primary/20 flex items-center justify-center">
                  <Package className="h-4 w-4 sm:h-5 sm:w-5 text-primary" />
                </div>
                <div>
                  <div className="text-sm sm:text-base font-semibold">24 soat</div>
                  <div className="text-[10px] sm:text-xs text-muted-foreground">Yetkazib berish</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="container py-16 sm:py-20 md:py-24 border-t px-4 sm:px-6">
        <div className="text-center max-w-2xl mx-auto mb-10 sm:mb-16">
          <h2 className="text-2xl sm:text-3xl font-bold mb-3 sm:mb-4">Nima uchun TOPLA.UZ?</h2>
          <p className="text-sm sm:text-base text-muted-foreground">
            Bizning platformamiz sotuvchilar uchun barcha zarur vositalarni taqdim etadi
          </p>
        </div>
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6 md:gap-8">
          <Card className="border-2 hover:border-primary/50 transition-colors">
            <CardContent className="pt-6">
              <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                <Store className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-lg font-semibold mb-2">Oson do'kon ochish</h3>
              <p className="text-muted-foreground">
                5 daqiqada do'koningizni oching. Hech qanday texnik bilim talab etilmaydi.
              </p>
            </CardContent>
          </Card>
          <Card className="border-2 hover:border-primary/50 transition-colors">
            <CardContent className="pt-6">
              <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                <Shield className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-lg font-semibold mb-2">Xavfsiz to'lovlar</h3>
              <p className="text-muted-foreground">
                Payme, Click, Uzum orqali xavfsiz to'lovlarni qabul qiling.
              </p>
            </CardContent>
          </Card>
          <Card className="border-2 hover:border-primary/50 transition-colors">
            <CardContent className="pt-6">
              <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                <Truck className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-lg font-semibold mb-2">Yetkazib berish</h3>
              <p className="text-muted-foreground">
                O'zbekiston bo'ylab tez yetkazib berish xizmati. Biz hamma narsani hal qilamiz.
              </p>
            </CardContent>
          </Card>
          <Card className="border-2 hover:border-primary/50 transition-colors">
            <CardContent className="pt-6">
              <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                <TrendingUp className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-lg font-semibold mb-2">Analitika</h3>
              <p className="text-muted-foreground">
                Sotuvlar, mijozlar va trendlar bo'yicha batafsil statistika.
              </p>
            </CardContent>
          </Card>
          <Card className="border-2 hover:border-primary/50 transition-colors">
            <CardContent className="pt-6">
              <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                <Users className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-lg font-semibold mb-2">Katta auditoriya</h3>
              <p className="text-muted-foreground">
                100,000+ faol foydalanuvchilar. Reklama va marketingsiz mijozlar.
              </p>
            </CardContent>
          </Card>
          <Card className="border-2 hover:border-primary/50 transition-colors">
            <CardContent className="pt-6">
              <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                <Headphones className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-lg font-semibold mb-2">24/7 Qo'llab-quvvatlash</h3>
              <p className="text-muted-foreground">
                Har qanday savolingizga tezkor javob. Telegram va telefon orqali.
              </p>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* How it Works */}
      <section id="how-it-works" className="bg-muted/50 py-16 sm:py-20 md:py-24">
        <div className="container px-4 sm:px-6">
          <div className="text-center max-w-2xl mx-auto mb-10 sm:mb-16">
            <h2 className="text-2xl sm:text-3xl font-bold mb-3 sm:mb-4">Qanday boshlash mumkin?</h2>
            <p className="text-sm sm:text-base text-muted-foreground">3 oddiy qadamda do'koningizni oching</p>
          </div>
          <div className="grid sm:grid-cols-3 gap-8 sm:gap-6 md:gap-8">
            <div className="text-center">
              <div className="h-12 w-12 sm:h-16 sm:w-16 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-xl sm:text-2xl font-bold mx-auto mb-4 sm:mb-6">
                1
              </div>
              <h3 className="text-lg sm:text-xl font-semibold mb-2">Ro'yxatdan o'ting</h3>
              <p className="text-sm sm:text-base text-muted-foreground">
                Telefon raqamingiz va shaxsiy ma'lumotlaringiz bilan ro'yxatdan o'ting
              </p>
            </div>
            <div className="text-center">
              <div className="h-12 w-12 sm:h-16 sm:w-16 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-xl sm:text-2xl font-bold mx-auto mb-4 sm:mb-6">
                2
              </div>
              <h3 className="text-lg sm:text-xl font-semibold mb-2">Do'kon oching</h3>
              <p className="text-sm sm:text-base text-muted-foreground">
                Do'kon nomini, logosini va tavsifini kiriting. Hujjatlarni yuklang
              </p>
            </div>
            <div className="text-center">
              <div className="h-12 w-12 sm:h-16 sm:w-16 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-xl sm:text-2xl font-bold mx-auto mb-4 sm:mb-6">
                3
              </div>
              <h3 className="text-lg sm:text-xl font-semibold mb-2">Sotishni boshlang</h3>
              <p className="text-sm sm:text-base text-muted-foreground">
                Mahsulotlaringizni qo'shing va buyurtmalarni qabul qilishni boshlang
              </p>
            </div>
          </div>
          <div className="text-center mt-8 sm:mt-12">
            <Button size="lg" className="w-full sm:w-auto" asChild>
              <Link href="/vendor/register">Hoziroq boshlash</Link>
            </Button>
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section id="testimonials" className="container py-16 sm:py-20 md:py-24 px-4 sm:px-6">
        <div className="text-center max-w-2xl mx-auto mb-10 sm:mb-16">
          <h2 className="text-2xl sm:text-3xl font-bold mb-3 sm:mb-4">Sotuvchilarimiz fikrlari</h2>
          <p className="text-sm sm:text-base text-muted-foreground">
            Minglab sotuvchilar bizga ishonadi
          </p>
        </div>
        <div className="grid sm:grid-cols-2 md:grid-cols-3 gap-4 sm:gap-6 md:gap-8">
          {[
            {
              name: "Aziz Karimov",
              shop: "TechStore UZ",
              text: "TOPLA.UZ orqali oylik daromadim 3 barobar oshdi. Ajoyib platforma!",
            },
            {
              name: "Madina Rahimova",
              shop: "Fashion House",
              text: "Mijozlar bilan muloqot juda qulay. Yetkazib berish xizmati a'lo darajada.",
            },
            {
              name: "Bobur Toshmatov",
              shop: "Mebel Market",
              text: "Boshqa platformalardan farqi - bu yerda haqiqiy sotuvlar bor. Tavsiya qilaman!",
            },
          ].map((testimonial, i) => (
            <Card key={i}>
              <CardContent className="pt-6">
                <div className="flex gap-1 mb-4">
                  {[1, 2, 3, 4, 5].map((star) => (
                    <Star key={star} className="h-4 w-4 fill-yellow-400 text-yellow-400" />
                  ))}
                </div>
                <p className="text-muted-foreground mb-4">"{testimonial.text}"</p>
                <div>
                  <div className="font-semibold">{testimonial.name}</div>
                  <div className="text-sm text-muted-foreground">{testimonial.shop}</div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-primary text-primary-foreground py-16 sm:py-20 md:py-24">
        <div className="container text-center px-4 sm:px-6">
          <h2 className="text-2xl sm:text-3xl md:text-4xl font-bold mb-3 sm:mb-4">
            Biznesingizni bugun boshlang!
          </h2>
          <p className="text-sm sm:text-base text-primary-foreground/80 max-w-2xl mx-auto mb-6 sm:mb-8">
            1,500+ sotuvchi allaqachon TOPLA.UZ da muvaffaqiyatli savdo qilmoqda.
            Siz ham qo'shiling!
          </p>
          <div className="flex flex-col sm:flex-row gap-3 sm:gap-4 justify-center">
            <Button size="lg" variant="secondary" className="w-full sm:w-auto" asChild>
              <Link href="/vendor/register">Bepul ro'yxatdan o'tish</Link>
            </Button>
            <Button size="lg" variant="outline" className="w-full sm:w-auto bg-transparent border-white hover:bg-white/10" asChild>
              <Link href="/contact">Biz bilan bog'lanish</Link>
            </Button>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t py-8 sm:py-12">
        <div className="container px-4 sm:px-6">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 sm:gap-8">
            <div className="col-span-2 md:col-span-1">
              <Link href="/" className="flex items-center gap-2 mb-4">
                <div className="h-7 w-7 sm:h-8 sm:w-8 rounded-lg bg-primary flex items-center justify-center">
                  <ShoppingBag className="h-4 w-4 sm:h-5 sm:w-5 text-primary-foreground" />
                </div>
                <span className="text-lg sm:text-xl font-bold">TOPLA.UZ</span>
              </Link>
              <p className="text-xs sm:text-sm text-muted-foreground">
                O'zbekistonning eng yirik online marketplace platformasi
              </p>
            </div>
            <div>
              <h4 className="font-semibold mb-3 sm:mb-4 text-sm sm:text-base">Sotuvchilar uchun</h4>
              <ul className="space-y-2 text-xs sm:text-sm text-muted-foreground">
                <li><Link href="/vendor/register" className="hover:text-primary">Ro'yxatdan o'tish</Link></li>
                <li><Link href="/vendor/login" className="hover:text-primary">Kirish</Link></li>
                <li><Link href="#" className="hover:text-primary">Yordam markazi</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold mb-3 sm:mb-4 text-sm sm:text-base">Kompaniya</h4>
              <ul className="space-y-2 text-xs sm:text-sm text-muted-foreground">
                <li><Link href="#" className="hover:text-primary">Biz haqimizda</Link></li>
                <li><Link href="/contact" className="hover:text-primary">Aloqa</Link></li>
                <li><Link href="#" className="hover:text-primary">Blog</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold mb-3 sm:mb-4 text-sm sm:text-base">Aloqa</h4>
              <ul className="space-y-2 text-xs sm:text-sm text-muted-foreground">
                <li>📞 +998 90 123 45 67</li>
                <li>📧 info@topla.uz</li>
                <li>📍 Toshkent sh., Chilonzor t.</li>
              </ul>
            </div>
          </div>
          <div className="border-t mt-6 sm:mt-8 pt-6 sm:pt-8 text-center text-xs sm:text-sm text-muted-foreground">
            © 2024-2026 TOPLA.UZ. Barcha huquqlar himoyalangan.
          </div>
        </div>
      </footer>
    </div>
  );
}
