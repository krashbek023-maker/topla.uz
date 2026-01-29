import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

interface CookieToSet {
  name: string;
  value: string;
  options: CookieOptions;
}

export async function updateSession(request: NextRequest) {
  let response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet: CookieToSet[]) {
          cookiesToSet.forEach(({ name, value }) => {
            request.cookies.set(name, value)
          })
          response = NextResponse.next({
            request: {
              headers: request.headers,
            },
          })
          cookiesToSet.forEach(({ name, value, options }) => {
            response.cookies.set(name, value, options)
          })
        },
      },
    }
  )

  // Refreshing the auth token
  const {
    data: { user },
  } = await supabase.auth.getUser()


  // Protected routes logic
  const pathname = request.nextUrl.pathname;

  // Admin routes protection
  if (pathname.startsWith('/admin')) {
    // Allow access to admin login page
    if (pathname === '/admin/login') {
      // If already logged in, redirect to dashboard
      if (user) {
        return NextResponse.redirect(new URL('/admin/dashboard', request.url))
      }
      return response
    }

    // All other admin routes require authentication
    if (!user) {
      return NextResponse.redirect(new URL('/admin/login', request.url))
    }
  }

  // Vendor routes protection
  if (pathname.startsWith('/vendor')) {
    // Allow access to login and register pages
    if (pathname === '/vendor/login' || pathname === '/vendor/register') {
      // If already logged in, redirect to dashboard
      if (user) {
        return NextResponse.redirect(new URL('/vendor/dashboard', request.url))
      }
      return response
    }

    // All other vendor routes require authentication
    if (!user) {
      return NextResponse.redirect(new URL('/vendor/login', request.url))
    }
  }

  return response
}
