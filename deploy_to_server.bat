@echo off
echo ========================================================
echo DriveON - Serverga Yuklash (Deployment)
echo ========================================================
echo Parol so'ralganda "TestServer2026!" ni kiriting.
echo.

echo 1-qadam: Arxivlanmoqda (node_modules va keraksiz fayllarsiz)...
tar.exe -czf deploy.tar.gz backend/ web/ docker-compose.yml --exclude="backend/target" --exclude="web/node_modules" --exclude="web/dist" --exclude="*/.git/*"

echo.
echo 2-qadam: Serverda papka yaratilmoqda...
ssh -o ProxyCommand="cloudflared access ssh --hostname %%h" team@server.uzinc.uz "mkdir -p ~/DriveON"

echo.
echo 3-qadam: Arxiv serverga yuklanmoqda...
scp -o ProxyCommand="cloudflared access ssh --hostname %%h" deploy.tar.gz team@server.uzinc.uz:~/DriveON/

echo.
echo 4-qadam: Serverda Docker konteynerlar ishga tushirilmoqda...
ssh -o ProxyCommand="cloudflared access ssh --hostname %%h" team@server.uzinc.uz "cd ~/DriveON && tar -xzf deploy.tar.gz && sudo docker-compose down && sudo docker-compose up --build -d && rm deploy.tar.gz"

echo.
echo 5-qadam: Tozalanmoqda...
del deploy.tar.gz

echo.
echo ========================================================
echo YUKLASH TUGADI! Dastur serverda ishga tushirildi.
echo.
echo API Backend: http://server.uzinc.uz:8080
echo Admin Panel: http://server.uzinc.uz:3000
echo ========================================================
pause
