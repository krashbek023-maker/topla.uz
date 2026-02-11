import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';

export interface JwtPayload {
  userId: string;
  role: string;
  phone: string;
}

export function generateToken(payload: JwtPayload): string {
  return jwt.sign(payload, env.JWT_SECRET, { expiresIn: env.JWT_EXPIRES_IN as any });
}

export function generateRefreshToken(payload: JwtPayload): string {
  const refreshSecret = env.JWT_REFRESH_SECRET || env.JWT_SECRET + '-refresh';
  return jwt.sign(payload, refreshSecret, { expiresIn: env.JWT_REFRESH_EXPIRES_IN as any });
}

export function verifyToken(token: string): JwtPayload {
  return jwt.verify(token, env.JWT_SECRET) as JwtPayload;
}

export function verifyRefreshToken(token: string): JwtPayload {
  const refreshSecret = env.JWT_REFRESH_SECRET || env.JWT_SECRET + '-refresh';
  return jwt.verify(token, refreshSecret) as JwtPayload;
}
