package main

import (
    "fmt"
    "os"
    "time"
    "github.com/pquerna/otp/totp"
)

func main() {
    secret := os.Getenv("TOTP_SECRET")
    if secret == "" {
        panic("No TOTP_SECRET")
    }

    code, err := totp.GenerateCode(secret, time.Now())
    if err != nil {
        panic(err)
    }

    fmt.Println("TOTP:", code)
}

