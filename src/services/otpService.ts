import { convexClient } from './convexClient';
import { api } from '../../convex/_generated/api';

export class OtpService {
  /**
   * Generate a random 6-digit OTP
   */
  static generateOtp(): string {
    const min = 100000;
    const max = 900000;
    return String(Math.floor(min + Math.random() * max));
  }

  /**
   * Send OTP via email using Convex emailService:sendOtpEmail
   */
  static async sendOtp(email: string, otpValue: string): Promise<{ success: boolean; message: string; mock?: boolean }> {
    try {
      const res = await convexClient.action(api.emailService.sendOtpEmail, {
        email,
        otp: otpValue,
      });
      return {
        success: true,
        message: `OTP sent to ${email}`,
        mock: !!res.mock,
      };
    } catch (e) {
      return {
        success: false,
        message: `Failed to send OTP email: ${e instanceof Error ? e.message : String(e)}`,
      };
    }
  }

  /**
   * Verify OTP (local comparison)
   */
  static verifyOtp(inputOtp: string, generatedOtp: string): boolean {
    return inputOtp === generatedOtp;
  }
}
