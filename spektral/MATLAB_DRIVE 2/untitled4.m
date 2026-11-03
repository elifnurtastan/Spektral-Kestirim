disp('Türkiye (IU.ANTO) Sismik verileri IRIS sunucularından çekiliyor, lütfen bekleyin...');

% 1. 6 ŞUBAT DEPREM ANI (Saat 01:10 ile 01:40 UTC arası)
% Hata veren "output=sac" kısmını "format=sac.zip" olarak düzelttik
url_deprem = 'https://service.iris.edu/irisws/timeseries/1/query?net=IU&sta=ANTO&loc=00&cha=BHZ&starttime=2023-02-06T01:10:00&endtime=2023-02-06T01:40:00&format=sac.zip';
websave('TR_deprem_ani.zip', url_deprem);
dosyalar = unzip('TR_deprem_ani.zip');
dosya_deprem = dosyalar{1}; % Zipten çıkan SAC dosyasının gerçek adını otomatik alır
disp(['1/3: Deprem anı verisi indirildi ve zipten çıkarıldı: ', dosya_deprem]);

% 2. 3 GÜN ÖNCESİ (3 Şubat)
url_3gun = 'https://service.iris.edu/irisws/timeseries/1/query?net=IU&sta=ANTO&loc=00&cha=BHZ&starttime=2023-02-03T01:10:00&endtime=2023-02-03T01:40:00&format=sac.zip';
websave('TR_3_gun_once.zip', url_3gun);
dosyalar = unzip('TR_3_gun_once.zip');
dosya_3gun = dosyalar{1};
disp(['2/3: 3 gün öncesinin verisi indirildi: ', dosya_3gun]);

% 3. 3 AY ÖNCESİ (6 Kasım 2022)
url_3ay = 'https://service.iris.edu/irisws/timeseries/1/query?net=IU&sta=ANTO&loc=00&cha=BHZ&starttime=2022-11-06T01:10:00&endtime=2022-11-06T01:40:00&format=sac.zip';
websave('TR_3_ay_once.zip', url_3ay);
dosyalar = unzip('TR_3_ay_once.zip');
dosya_3ay = dosyalar{1};
disp(['3/3: 3 ay öncesinin verisi indirildi: ', dosya_3ay]);

disp('Tüm veriler hazır! Workspace alanına dosya isimleri düştü.');

% 1.5. 1 GÜN ÖNCESİ (5 Şubat)
url_1gun = 'https://service.iris.edu/irisws/timeseries/1/query?net=IU&sta=ANTO&loc=00&cha=BHZ&starttime=2023-02-05T01:10:00&endtime=2023-02-05T01:40:00&format=sac.zip';
websave('TR_1_gun_once.zip', url_1gun);
dosyalar = unzip('TR_1_gun_once.zip');
dosya_1gun = dosyalar{1};
disp(['1.5/4: 1 gün öncesinin verisi indirildi: ', dosya_1gun]);