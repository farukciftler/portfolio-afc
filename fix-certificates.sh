#!/bin/bash

# Sertifika klasörlerini tarayıp nginx config'lerini otomatik güncelleme scripti

echo "=== Sertifika klasörlerini ve nginx config'lerini kontrol ediyorum ==="

# Local sertifika klasörlerini listele
echo "Mevcut sertifika klasörleri:"
if [ -d "./nginx/certbot/conf/live" ]; then
    ls -1 ./nginx/certbot/conf/live/ | grep -v README | while read cert_dir; do
        echo "  - $cert_dir"
    done
else
    echo "  Sertifika klasörü bulunamadı: ./nginx/certbot/conf/live"
fi

echo ""
echo "Nginx config dosyalarını güncelliyorum..."

# Tüm nginx config dosyalarını tara
for conf_file in ./nginx/conf.d/*.conf; do
    if [ -f "$conf_file" ]; then
        echo "İşleniyor: $conf_file"

        # Dosyada eski sertifika yolları var mı kontrol et
        if grep -q "ssl_certificate /etc/letsencrypt/live/.*\.com/fullchain.pem" "$conf_file"; then
            echo "  Eski sertifika yolu bulundu, güncelliyorum..."

            # server_name'den domain'i çıkar
            domain=$(grep "server_name" "$conf_file" | head -1 | sed 's/.*server_name//' | sed 's/;//' | sed 's/^[[:space:]]*//' | awk '{print $1}')

            if [ ! -z "$domain" ]; then
                echo "  Domain: $domain"

                # Local gerçek sertifika klasörünü bul
                actual_cert_dir=$(ls -1 ./nginx/certbot/conf/live/ | grep "^${domain}" | head -1)

                if [ ! -z "$actual_cert_dir" ]; then
                    echo "  Gerçek sertifika klasörü: $actual_cert_dir"

                    # Config dosyasındaki sertifika yollarını güncelle
                    sed -i "s|ssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem|ssl_certificate /etc/letsencrypt/live/${actual_cert_dir}/fullchain.pem|g" "$conf_file"
                    sed -i "s|ssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem|ssl_certificate_key /etc/letsencrypt/live/${actual_cert_dir}/privkey.pem|g" "$conf_file"

                    echo "  ✓ Config güncellendi"
                else
                    echo "  ✗ Sertifika klasörü bulunamadı: $domain"
                fi
            fi
        else
            echo "  Sertifika yolu zaten güncel"
        fi
        echo ""
    fi
done

echo "=== Nginx'i yeniden yüklüyorum ==="
docker compose exec nginx nginx -s reload

if [ $? -eq 0 ]; then
    echo "✓ Nginx başarıyla yeniden yüklendi"
else
    echo "✗ Nginx yeniden yüklenirken hata oluştu"
fi
