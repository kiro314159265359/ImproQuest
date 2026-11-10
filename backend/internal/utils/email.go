package utils

import (
	"fmt"
	"net/smtp"
	"os"
)

// SendPasswordResetEmail sends an email with the password reset link over SMTP.
func SendOTPEmail(email, otp string) error {
	host := os.Getenv("SMTP_HOST")
	port := os.Getenv("SMTP_PORT")
	username := os.Getenv("SMTP_USER")
	password := os.Getenv("SMTP_PASS")

	auth := smtp.PlainAuth("", username, password, host)

	body := fmt.Sprintf("Your password reset code is: %s\nThis code expires in 10 minutes.", otp)
	msg := []byte(
		"From: " + username + "\r\n" +
			"To: " + email + "\r\n" +
			"Subject: Your Password Reset Code\r\n" +
			"MIME-version: 1.0;\r\n" +
			"Content-Type: text/plain; charset=\"UTF-8\";\r\n" +
			"\r\n" +
			body + "\r\n",
	)

	addr := fmt.Sprintf("%s:%s", host, port)
	if err := smtp.SendMail(addr, auth, username, []string{email}, msg); err != nil {
		return fmt.Errorf("failed to send OTP email: %w", err)
	}
	return nil
}
