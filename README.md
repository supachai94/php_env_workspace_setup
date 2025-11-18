# PHP-FPM Docker Environment

โปรเจคนี้ประกอบด้วย Docker workspace ที่มี PHP-FPM เวอร์ชัน 7.4 และ 8.4/8.3 อยู่ใน container เดียวกัน โดยแต่ละเวอร์ชันจะเปิด port แยกกันเพื่อให้ nginx เรียกใช้งานได้

## Port Configuration

- **PHP 7.4 FPM**: Port `9000`
- **PHP 8.4/8.3 FPM**: Port `9001`

## โครงสร้างไฟล์

```
.
├── Dockerfile.workspace              # Dockerfile สำหรับ Development Workspace
├── php-fpm-workspace-74.conf         # Config สำหรับ PHP-FPM 7.4
├── php-fpm-workspace-84.conf         # Config สำหรับ PHP-FPM 8.4
├── php-fpm-workspace-83.conf         # Config สำหรับ PHP-FPM 8.3 (fallback)
├── php.ini                            # PHP configuration สำหรับ Laravel
├── start-php-fpm.sh                  # Script สำหรับเริ่ม PHP-FPM
├── docker-entrypoint.sh              # Entrypoint script สำหรับตั้งค่า permissions
├── docker-compose.yml                # Docker Compose configuration
└── www/                               # โฟลเดอร์สำหรับเก็บโค้ด PHP/Laravel (จะถูกสร้างอัตโนมัติ)
```

## การใช้งาน

### 1. Build และ Start Containers

```bash
docker-compose up -d --build
```

### 2. ตรวจสอบสถานะ Containers

```bash
docker-compose ps
```

### 3. ดู Logs

```bash
# ดู logs ของ workspace
docker-compose logs workspace
```

### 4. หยุด Containers

```bash
docker-compose down
```

## การเชื่อมต่อกับ Nginx

### ตัวอย่าง Nginx Configuration สำหรับ PHP 7.4

```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
    index index.php index.html;

    location ~ \.php$ {
        fastcgi_pass php-workspace:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

### ตัวอย่าง Nginx Configuration สำหรับ PHP 8.4/8.3

```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
    index index.php index.html;

    location ~ \.php$ {
        fastcgi_pass php-workspace:9001;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

**หมายเหตุ**: หาก nginx อยู่ใน Docker network เดียวกันกับ PHP-FPM container ให้ใช้ชื่อ service `php-workspace` แทน `localhost` หรือ `127.0.0.1`

### หาก Nginx อยู่บน Host Machine

หาก nginx ทำงานบน host machine (ไม่ใช่ใน Docker) ให้ใช้:

```nginx
fastcgi_pass 127.0.0.1:9000;  # สำหรับ PHP 7.4
fastcgi_pass 127.0.0.1:9001;  # สำหรับ PHP 8.4/8.3
```

## PHP Extensions ที่ติดตั้ง

Extensions ที่ติดตั้งสำหรับ Laravel:

- **pdo_mysql** - สำหรับเชื่อมต่อ MySQL/MariaDB
- **mbstring** - สำหรับจัดการ multibyte strings
- **exif** - สำหรับจัดการข้อมูล EXIF จากรูปภาพ
- **pcntl** - สำหรับ process control
- **bcmath** - สำหรับการคำนวณตัวเลขความแม่นยำสูง
- **gd** - สำหรับจัดการรูปภาพ
- **zip** - สำหรับจัดการไฟล์ ZIP (จำเป็นสำหรับ Composer)
- **intl** - สำหรับ internationalization (จำเป็นสำหรับ Laravel localization)
- **opcache** - สำหรับเพิ่มประสิทธิภาพการทำงาน
- **tokenizer** - สำหรับ Laravel Blade templating

## การทดสอบ

สร้างไฟล์ `www/index.php` เพื่อทดสอบ:

```php
<?php
phpinfo();
?>
```

จากนั้นเข้าถึงผ่าน nginx ที่ตั้งค่าไว้

## การตรวจสอบ PHP Version

```bash
# ตรวจสอบ PHP 7.4
docker-compose exec workspace php7.4 -v

# ตรวจสอบ PHP 8.4/8.3
docker-compose exec workspace php -v
```

## การใช้งานกับ Laravel

### 1. ติดตั้ง Laravel Project

```bash
# สร้าง Laravel project ใหม่
composer create-project laravel/laravel www

# หรือ clone project ที่มีอยู่แล้ว
git clone <your-repo> www
```

### 2. ตั้งค่า Permissions

ถ้าต้องการตั้งค่า permissions ด้วยตนเอง:

```bash
docker-compose exec workspace chown -R www-data:www-data /var/www/html/storage
docker-compose exec workspace chown -R www-data:www-data /var/www/html/bootstrap/cache
docker-compose exec workspace chmod -R 775 /var/www/html/storage
docker-compose exec workspace chmod -R 775 /var/www/html/bootstrap/cache
```

### 3. ติดตั้ง Dependencies

```bash
docker-compose exec workspace composer install
```

### 4. สร้าง .env File และ Generate Key

```bash
docker-compose exec workspace cp .env.example .env
docker-compose exec workspace php artisan key:generate
```

### 5. รัน Migrations

```bash
docker-compose exec workspace php artisan migrate
```

### 6. ตัวอย่าง Nginx Configuration สำหรับ Laravel

```nginx
server {
    listen 80;
    server_name laravel.test;
    root /var/www/html/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass php-workspace:9001;  # หรือ php-workspace:9000 สำหรับ PHP 7.4
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

**หมายเหตุสำคัญ**: 
- ใช้ `root /var/www/html/public;` ไม่ใช่ `/var/www/html` เพราะ Laravel ใช้โฟลเดอร์ `public` เป็น document root
- ต้องมี `try_files` directive เพื่อให้ Laravel routing ทำงานได้ถูกต้อง

### 7. ตรวจสอบ PHP Extensions ที่ติดตั้ง

```bash
# ตรวจสอบ PHP 7.4 extensions
docker-compose exec workspace php7.4 -m

# ตรวจสอบ PHP 8.4/8.3 extensions
docker-compose exec workspace php -m
```

### 8. ตรวจสอบ Laravel Requirements

```bash
docker-compose exec workspace php artisan about
```

## Development Workspace

Workspace container สำหรับการพัฒนา ที่มีทั้ง PHP 7.4 และ PHP 8.4 อยู่ใน container เดียวกัน

### 1. เข้าใช้งาน Workspace

```bash
# เข้าใช้งาน workspace container
docker-compose exec workspace bash

# หรือเข้าใช้งานแบบ interactive
docker-compose run --rm workspace bash
```

### 2. การสลับ PHP Version

ภายใน workspace container คุณสามารถใช้ PHP หลายเวอร์ชันได้:

```bash
# ใช้ PHP 7.4
php74 -v
/usr/bin/php7.4 -v

# ใช้ PHP 8.4 (หรือ 8.3 ถ้า 8.4 ยังไม่มี)
php -v
php84 -v
/usr/bin/php8.4 -v  # หรือ /usr/bin/php8.3 -v

# สลับ default PHP version
php74  # สลับเป็น PHP 7.4
php84  # สลับเป็น PHP 8.4 (หรือ 8.3)
```

### 3. ตรวจสอบ PHP Version ที่ติดตั้ง

```bash
# ตรวจสอบ PHP 7.4
docker-compose exec workspace php7.4 -v

# ตรวจสอบ PHP 8.4/8.3
docker-compose exec workspace php -v

# ตรวจสอบ PHP extensions
docker-compose exec workspace php -m
```

### 4. ใช้งาน Composer

```bash
# เข้าใช้งาน workspace
docker-compose exec workspace bash

# ติดตั้ง dependencies
composer install

# สร้าง Laravel project ใหม่
composer create-project laravel/laravel .

# ใช้ PHP version เฉพาะกับ Composer
php7.4 /usr/bin/composer install
php8.4 /usr/bin/composer install
```

### 5. ใช้งานกับ Laravel

```bash
# เข้าใช้งาน workspace
docker-compose exec workspace bash

# ติดตั้ง dependencies
composer install

# สร้าง .env file
cp .env.example .env

# Generate application key (ใช้ PHP version ที่ต้องการ)
php artisan key:generate

# รัน migrations
php artisan migrate

# รัน Laravel commands อื่นๆ
php artisan route:list
php artisan tinker
```

### 6. โครงสร้าง Workspace

Workspace container มี:
- **PHP 7.4** - พร้อม extensions สำหรับ Laravel
- **PHP 8.4** (หรือ 8.3 ถ้า 8.4 ยังไม่มี) - พร้อม extensions สำหรับ Laravel
- **Composer** - สำหรับจัดการ dependencies
- **Git** - สำหรับ version control
- **Vim/Nano** - Text editors
- **Build tools** - สำหรับ compile extensions

### 7. ใช้งาน PHP-FPM จาก Workspace

Workspace container มี PHP-FPM ทั้ง PHP 7.4 และ PHP 8.4/8.3 อยู่แล้ว สามารถใช้แทน containers แยกได้:

#### วิธีที่ 1: เริ่ม PHP-FPM แบบ Manual

```bash
# เข้าใช้งาน workspace
docker-compose exec workspace bash

# เริ่ม PHP 7.4 FPM
php-fpm7.4 -F -y /etc/php/7.4/fpm/php-fpm-workspace-74.conf

# เริ่ม PHP 8.4/8.3 FPM (ใน terminal อีกตัว)
php-fpm8.4 -F -y /etc/php/8.4/fpm/php-fpm-workspace-84.conf
# หรือ
php-fpm8.3 -F -y /etc/php/8.3/fpm/php-fpm-workspace-83.conf
```

#### วิธีที่ 2: เริ่ม PHP-FPM อัตโนมัติ

แก้ไข `docker-compose.yml` โดย uncomment บรรทัดนี้:

```yaml
workspace:
  # ...
  command: /usr/local/bin/start-php-fpm.sh
```

จากนั้น restart container:

```bash
docker-compose restart workspace
```

#### Port Configuration

- **PHP 7.4 FPM**: Port `9000`
- **PHP 8.4/8.3 FPM**: Port `9001`

#### ตัวอย่าง Nginx Configuration

```nginx
# สำหรับ PHP 7.4
fastcgi_pass php-workspace:9000;

# สำหรับ PHP 8.4/8.3
fastcgi_pass php-workspace:9001;
```

### 8. หมายเหตุ

- โฟลเดอร์ `www` จะถูก map ไปที่ `/var/www/html` ใน workspace container
- Default PHP version คือ 8.4 (หรือ 8.3 ถ้า 8.4 ยังไม่มี)
- สามารถใช้ PHP หลายเวอร์ชันพร้อมกันได้โดยระบุ path เต็ม
- Workspace สามารถใช้เป็น PHP-FPM server ได้โดยเปิด port 9000 และ 9001
- ถ้าต้องการให้ PHP-FPM ทำงานอัตโนมัติ ให้ uncomment `command` ใน docker-compose.yml

