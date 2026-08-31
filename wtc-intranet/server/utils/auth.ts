import jwt from 'jsonwebtoken'
import { getCookie, setCookie, deleteCookie, H3Event } from 'h3'

const JWT_SECRET = process.env.JWT_SECRET || 'fallback-secret'
const COOKIE_NAME = 'wtc_session'

export interface SessionUser {
    email: string
    name: string
}

export function createSession(event: H3Event, user: SessionUser) {
    const token = jwt.sign(user, JWT_SECRET, { expiresIn: '30d' })
    setCookie(event, COOKIE_NAME, token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'lax',
        maxAge: 60 * 60 * 24 * 30
    })
}

export function getSession(event: H3Event): SessionUser | null {
    const token = getCookie(event, COOKIE_NAME)
    if (!token) return null
    try {
        return jwt.verify(token, JWT_SECRET) as SessionUser
    } catch {
        return null
    }
}

export function clearSession(event: H3Event) {
    deleteCookie(event, COOKIE_NAME)
}

export function isAllowedEmail(email: string): boolean {
    const allowed = (process.env.ALLOWED_EMAILS || '').split(',').map(e => e.trim().toLowerCase())
    return allowed.includes(email.toLowerCase())
}