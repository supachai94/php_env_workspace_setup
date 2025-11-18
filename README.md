# PHP-FPM Docker Environment

โปรเจคนี้ประกอบด้วย Docker workspace ที่มี PHP-FPM เวอร์ชัน 7.4 และ 8.4 อยู่ใน container เดียวกัน โดยแต่ละเวอร์ชันจะเปิด port แยกกันเพื่อให้ nginx เรียกใช้งานได้

## Port Configuration

- **PHP 7.4 FPM**: Port `9000`
- **PHP 8.4 FPM**: Port `9001`

## โครงสร้างไฟล์

```
.
├── Dockerfile.workspace              # Dockerfile สำหรับ Development Workspace
├── php-fpm-workspace-74.conf         # Config สำหรับ PHP-FPM 7.4
├── php-fpm-workspace-84.conf         # Config สำหรับ PHP-FPM 8.4
├── php.ini                            # PHP configuration สำหรับ Laravel
├── start-php-fpm.sh                  # Script สำหรับเริ่ม PHP-FPM
├── docker-entrypoint.sh              # Entrypoint script สำหรับตั้งค่า permissions
├── docker-compose.yml                # Docker Compose configuration
├── .gitignore                        # Git ignore rules
├── .gitattributes                    # Git attributes
└── www/                               # โฟลเดอร์สำหรับเก็บโค้ด PHP/Laravel (จะถูกสร้างอัตโนมัติ)
```

## Git Repository

โปรเจคนี้มี Git repository อยู่แล้ว สามารถใช้งานได้ทันที:

```bash
# ตรวจสอบสถานะ
git status

# ดู commit history
git log

# สร้าง branch ใหม่
git checkout -b feature/your-feature

# เพิ่ม remote repository (ถ้าต้องการ)
git remote add origin <your-repo-url>
git push -u origin master
```

**หมายเหตุ**: โฟลเดอร์ `www/` ถูก ignore โดย Git เพื่อไม่ให้ commit โค้ดโปรเจคเข้าไปใน repository นี้

## การใช้งาน

### 1. Build และ Start Containers

```bash
docker-compose up -d --build
```

**หมายเหตุ**: PHP-FPM จะเริ่มทำงานอัตโนมัติเมื่อ container เริ่มต้น พร้อมใช้งานกับ nginx ทันที

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

### ตัวอย่าง Nginx Configuration สำหรับ PHP 8.4

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
fastcgi_pass 127.0.0.1:9001;  # สำหรับ PHP 8.4
```

## PHP Extensions ที่ติดตั้ง

Extensions ที่ติดตั้งสำหรับ Laravel 10:

### Extensions ที่จำเป็นสำหรับ Laravel 10:
- **pdo_mysql** - สำหรับเชื่อมต่อ MySQL/MariaDB
- **mbstring** - สำหรับจัดการ multibyte strings (จำเป็น)
- **xml** - สำหรับ XML processing (จำเป็น)
- **dom** - สำหรับ DOM manipulation (จำเป็น)
- **fileinfo** - สำหรับตรวจสอบประเภทไฟล์ (จำเป็น)
- **tokenizer** - สำหรับ Laravel Blade templating (จำเป็น)
- **bcmath** - สำหรับการคำนวณตัวเลขความแม่นยำสูง (จำเป็น)
- **curl** - สำหรับ HTTP requests (จำเป็น)
- **json** - สำหรับ JSON processing (มากับ php-common)
- **openssl** - สำหรับ encryption (มากับ php-common)
- **pcre** - สำหรับ regular expressions (มากับ php-common)
- **ctype** - สำหรับ character type checking (มากับ php-common)

### Extensions เพิ่มเติม:
- **gd** - สำหรับจัดการรูปภาพ
- **zip** - สำหรับจัดการไฟล์ ZIP (จำเป็นสำหรับ Composer)
- **intl** - สำหรับ internationalization (จำเป็นสำหรับ Laravel localization)
- **opcache** - สำหรับเพิ่มประสิทธิภาพการทำงาน
- **exif** - สำหรับจัดการข้อมูล EXIF จากรูปภาพ
- **pcntl** - สำหรับ process control

**หมายเหตุ**: Laravel 10 ต้องการ PHP >= 8.1 ดังนั้นควรใช้ PHP 8.4 (PHP 7.4 ไม่รองรับ Laravel 10)

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

# ตรวจสอบ PHP 8.4
docker-compose exec workspace php -v
```

## การใช้งานกับ Laravel

### Laravel Version Support

- **Laravel 10**: ต้องการ PHP >= 8.1 (แนะนำใช้ PHP 8.4) ✅
- **Laravel 9**: ต้องการ PHP >= 8.0 (รองรับ PHP 8.4) ✅
- **Laravel 8**: ต้องการ PHP >= 7.3 (รองรับ PHP 7.4 และ 8.4) ✅

### 1. ติดตั้ง Laravel Project

```bash
# สร้าง Laravel 10 project ใหม่ (ใช้ PHP 8.4)
docker-compose exec workspace composer create-project laravel/laravel:^10.0 www

# หรือสร้าง Laravel 9 project
docker-compose exec workspace composer create-project laravel/laravel:^9.0 www

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

# ตรวจสอบ PHP 8.4 extensions
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

# ใช้ PHP 8.4
php -v
php84 -v
/usr/bin/php8.4 -v

# สลับ default PHP version
php74  # สลับเป็น PHP 7.4
php84  # สลับเป็น PHP 8.4
```

### 3. ตรวจสอบ PHP Version ที่ติดตั้ง

```bash
# ตรวจสอบ PHP 7.4
docker-compose exec workspace php7.4 -v

# ตรวจสอบ PHP 8.4
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
- **PHP 8.4** - พร้อม extensions สำหรับ Laravel
- **Composer** - สำหรับจัดการ dependencies
- **Git** - สำหรับ version control
- **Vim/Nano** - Text editors
- **Build tools** - สำหรับ compile extensions

### 7. ใช้งาน PHP-FPM จาก Workspace

**PHP-FPM จะเริ่มทำงานอัตโนมัติเมื่อ container เริ่มต้น** พร้อมใช้งานกับ nginx ทันที

Workspace container มี PHP-FPM ทั้ง PHP 7.4 และ PHP 8.4 ทำงานพร้อมกัน:

- **PHP 7.4 FPM**: ทำงานบน port 9000 อัตโนมัติ
- **PHP 8.4 FPM**: ทำงานบน port 9001 อัตโนมัติ

#### ตรวจสอบสถานะ PHP-FPM

```bash
# ตรวจสอบว่า PHP-FPM ทำงานอยู่
docker-compose exec workspace ps aux | grep php-fpm

# ตรวจสอบ logs
docker-compose logs workspace
```

#### เริ่ม PHP-FPM แบบ Manual (ถ้าต้องการ)

ถ้าต้องการเริ่ม PHP-FPM แบบ manual (เช่น หลังจากเข้า container):

```bash
# เข้าใช้งาน workspace
docker-compose exec workspace bash

# เริ่ม PHP 7.4 FPM
php-fpm7.4 -F -y /etc/php/7.4/fpm/php-fpm-workspace-74.conf

# เริ่ม PHP 8.4 FPM (ใน terminal อีกตัว)
php-fpm8.4 -F -y /etc/php/8.4/fpm/php-fpm-workspace-84.conf
```

#### Port Configuration

- **PHP 7.4 FPM**: Port `9000`
- **PHP 8.4 FPM**: Port `9001`

#### ตัวอย่าง Nginx Configuration

```nginx
# สำหรับ PHP 7.4
fastcgi_pass php-workspace:9000;

# สำหรับ PHP 8.4
fastcgi_pass php-workspace:9001;
```

### 8. หมายเหตุ

- โฟลเดอร์ `www` จะถูก map ไปที่ `/var/www/html` ใน workspace container
- Default PHP version คือ 8.4
- สามารถใช้ PHP หลายเวอร์ชันพร้อมกันได้โดยระบุ path เต็ม
- **PHP-FPM เริ่มทำงานอัตโนมัติเมื่อ container เริ่มต้น** พร้อมใช้งานกับ nginx
- Workspace ใช้เป็น PHP-FPM server โดยเปิด port 9000 (PHP 7.4) และ 9001 (PHP 8.4)
- ถ้าต้องการเข้าใช้งาน container แบบ interactive ให้ใช้ `docker-compose exec workspace bash` (PHP-FPM จะยังทำงานอยู่)

