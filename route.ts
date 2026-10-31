import { NextResponse } from "next/server";
import { createClient } from '@supabase/supabase-js';
import { createHash, timingSafeEqual } from 'node:crypto';
import { COOKIE_NAME, createAdminToken } from "@/lib/admin-auth";
export async function POST(request: Request) {
 const body = (await request.json().catch(() => null)) as { code?: string } | null;
 const expected=process.env.ADMIN_CODE, key=process.env.SUPABASE_SERVICE_ROLE_KEY, url=process.env.NEXT_PUBLIC_SUPABASE_URL;
 if (!expected || !key || !url || expected.length<16) return NextResponse.json({error:'Admin configuration missing'}, {status:503});
 const ip=(request.headers.get('x-forwarded-for') ?? 'unknown').split(',')[0].trim();
 const hash=createHash('sha256').update(ip+':'+expected).digest('hex');
 const a=Buffer.from(typeof body?.code==='string'?body.code:''); const b=Buffer.from(expected);
 const correct=a.length===b.length && timingSafeEqual(a,b);
 const db=createClient(url,key,{auth:{persistSession:false,autoRefreshToken:false}});
 const {data:allowed,error}=await db.rpc('check_admin_login_attempt',{p_hash:hash,p_success:correct});
 if(error) return NextResponse.json({error:'Admin security check unavailable'}, {status:503});
 if(!allowed || !correct) return NextResponse.json({ok:false}, {status:429});
 const response=NextResponse.json({ok:true});
 response.cookies.set(COOKIE_NAME,createAdminToken(),{httpOnly:true,secure:process.env.NODE_ENV==='production',sameSite:'strict',path:'/',maxAge:7200});
 return response;
}
