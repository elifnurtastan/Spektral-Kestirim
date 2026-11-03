disp('Sinyaller işleniyor ve Welch PSD grafiği çiziliyor...');

% 1. VERİLERİ OKUMA VE DC OFSETİNİ TEMİZLEME
[t1, y1] = basit_sac_oku(dosya_3ay);
y1 = detrend(y1 - mean(y1));

[t2, y2] = basit_sac_oku(dosya_3gun);
y2 = detrend(y2 - mean(y2));

[t3, y3] = basit_sac_oku(dosya_deprem);
y3 = detrend(y3 - mean(y3));

% Örnekleme Frekansı (fs) tespiti
fs = round(1 / (t3(2) - t3(1))); 

% 2. WELCH PSD PARAMETRELERİ
window_sec = 40;              % 40 saniyelik pencereler (Daha pürüzsüz ve net grafik için)
nperseg = window_sec * fs;    % Penceredeki örnek sayısı
noverlap = floor(nperseg/2);  % %50 örtüşme
nfft = nperseg;               % Çözünürlük

% PSD Hesaplama
[pxx_3ay, f_3ay]       = pwelch(y1, hamming(nperseg), noverlap, nfft, fs);
[pxx_3gun, f_3gun]     = pwelch(y2, hamming(nperseg), noverlap, nfft, fs);
[pxx_deprem, f_deprem] = pwelch(y3, hamming(nperseg), noverlap, nfft, fs);

% 3. BÜYÜK FİNAL GRAFİĞİ (GÖRSELLEŞTİRME)
figure('Name', 'Türkiye (IU.ANTO) Spektral Kıyaslama', 'Color', 'w', 'Position', [100, 100, 1000, 600]);

% Çizimler (Log-Log Ölçekte)
loglog(f_3ay, pxx_3ay, 'Color', [0.2 0.8 0.2], 'LineWidth', 1.5, 'DisplayName', '3 Ay Önce (Sakin Arka Plan)');
hold on;
loglog(f_3gun, pxx_3gun, 'Color', [0.2 0.2 0.8], 'LineWidth', 1.5, 'DisplayName', '3 Gün Önce (Öncü Evre)');
loglog(f_deprem, pxx_deprem, 'Color', [0.8 0.1 0.1], 'LineWidth', 2, 'DisplayName', '6 Şubat Deprem Anı (Mw 7.8)');

% Eksenler, Etiketler ve Makyaj
title('Türkiye (IU.ANTO) İstasyonu: Kahramanmaraş Depremi Welch PSD Kıyaslaması', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Frekans (Hz)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Güç Spektral Yoğunluğu (V^2/Hz)', 'FontSize', 12, 'FontWeight', 'bold');

% Sismolojide odaklanılan 0.05 Hz ile 10 Hz aralığı
xlim([0.05 10]); 
grid on;

% Grid çizgilerini daha estetik yapalım
ax = gca;
ax.GridAlpha = 0.3;
ax.MinorGridAlpha = 0.3;

legend('Location', 'southwest', 'FontSize', 11);

%% 4. GAUSS EĞRİSİ UYDURMA (Gaussian Curve Fitting)
disp('Deprem anı verisi için Gauss eğrisi uyduruluyor...');

% Sadece 0.1 Hz ile 1 Hz arasındaki en tehlikeli sismik bölgeye odaklanalım
ilgi_alani = (f_deprem >= 0.1) & (f_deprem <= 1.0);
f_odak = f_deprem(ilgi_alani);
pxx_odak = pxx_deprem(ilgi_alani);

% 1 Gauss terimli model oluştur (a*exp(-((x-b)/c)^2))
gauss_model = fit(f_odak, pxx_odak, 'gauss1');

% Sonuçları Ekrana Yazdır
disp('--- GAUSS MODELİ PARAMETRELERİ ---');
fprintf('Maksimum Güç (Genlik): %.4f\n', gauss_model.a1);
fprintf('Merkez Frekansı (Rezonans): %.4f Hz\n', gauss_model.b1);
fprintf('Eğri Genişliği (Varyans): %.4f\n', gauss_model.c1);

% Gauss Eğrisini Çizdirme
figure('Name', 'Gauss Curve Fitting', 'Color', 'w');
plot(gauss_model, f_odak, pxx_odak);
title('Deprem Anı PSD Zirvesine Gauss Eğrisi Uydurma', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Frekans (Hz)');
ylabel('Güç');
grid on;
legend('Gerçek PSD Verisi', 'Uydurulan Gauss Eğrisi', 'Location', 'northeast');

%% 7. DEPREM ÖNCESİ, ANI VE SONRASI: ZAMAN SERİSİ VE SPEKTROGRAM
disp('Zaman-Frekans Isı Haritası (Spektrogram) oluşturuluyor, lütfen bekleyin...');

% Zaman eksenini saniyeden dakikaya çevirelim (Daha rahat okumak için)
t_dakika = (0:length(y3)-1) / (fs * 60);

figure('Name', 'Deprem Öncesi-Anı-Sonrası Analizi', 'Color', 'w', 'Position', [100, 50, 1100, 750]);

% --- ÜST GRAFİK: Zaman Serisi (Ham Genlik) ---
subplot(2,1,1);
plot(t_dakika, y3, 'k', 'LineWidth', 0.5);
hold on;

% 7. Dakikaya (01:17 Deprem Anı) kırmızı dikey çizgi çekiyoruz
xline(7, 'r', 'DEPREM VURUYOR (01:17 UTC)', 'LineWidth', 2, 'LabelVerticalAlignment', 'top', 'FontSize', 11, 'FontWeight', 'bold');

title('Kahramanmaraş Depremi: 30 Dakikalık Zaman Serisi (IU.ANTO)', 'FontSize', 13, 'FontWeight', 'bold');
xlabel('Zaman (Dakika) - Kayıt Başlangıcı: 01:10 UTC', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Genlik', 'FontSize', 11, 'FontWeight', 'bold');
xlim([0 30]);
grid on;

% Bölgeleri isimlendirme
text(3.5, max(y3)*0.75, 'DEPREM ÖNCESİ (Sessizlik)', 'HorizontalAlignment', 'center', 'Color', 'b', 'FontWeight', 'bold', 'FontSize', 10);
text(18, max(y3)*0.75, 'DEPREM ANI VE SONRASI (Sarsıntı ve Sönümlenme)', 'HorizontalAlignment', 'center', 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 10);


% --- ALT GRAFİK: Spektrogram (Zaman-Frekans Isı Haritası) ---
subplot(2,1,2);
pencere_saniye = 15;            % 15 saniyelik pencerelerle analiz
nperseg = pencere_saniye * fs;
noverlap = round(nperseg * 0.9); % Zaman çözünürlüğünü artırmak için %90 örtüşme
nfft = 1024;

% Spektrogram matrislerini hesapla
[S, F, T, P] = spectrogram(y3, hamming(nperseg), noverlap, nfft, fs);
T_dakika = T / 60; % X ekseni için saniyeyi dakikaya çevir

% Isı haritasını (Logaritmik Güç) çizdir
surf(T_dakika, F, 10*log10(P), 'EdgeColor', 'none');
axis xy; axis tight; view(0,90);

% Renk paletini enerjiye uygun (mavi=soğuk, kırmızı=sıcak) ayarla
colormap(jet);
c = colorbar;
c.Label.String = 'Sismik Güç (dB/Hz)';
c.Label.FontWeight = 'bold';

hold on;
% Haritanın üzerine de deprem anı çizgisini ekleyelim
xline(7, 'w', 'DEPREM ANI', 'LineWidth', 2, 'LabelVerticalAlignment', 'top', 'FontSize', 11, 'FontWeight', 'bold');

title('Zaman-Frekans Analizi: Hangi Frekans Ne Zaman Ortaya Çıktı?', 'FontSize', 13, 'FontWeight', 'bold');
xlabel('Zaman (Dakika)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Frekans (Hz)', 'FontSize', 11, 'FontWeight', 'bold');

% Sismik enerjinin yoğun olduğu 0-5 Hz aralığına zoom yapıyoruz
ylim([0 5]); 
xlim([0 30]);

%% 8. ÜÇ DÖNEMİN HAM İŞARET (ZAMAN SERİSİ) KIYASLAMASI
disp('3 farklı döneme ait ham sismik sinyaller çizdiriliyor...');

% Bütün kayıtlar 30 dakika olduğu için ortak bir zaman ekseni (dakika) oluşturalım
% (Örnekleme frekansını fs olarak daha önce hesaplamıştık)
N_ornek = length(y3); 
t_ortak_dakika = (0:N_ornek-1) / (fs * 60); 

figure('Name', 'Ham İşaret Kıyaslaması (Zaman Serisi)', 'Color', 'w', 'Position', [100, 50, 1000, 800]);

% --- 1. 3 AY ÖNCE (Sakin Arka Plan) ---
subplot(3,1,1);
plot(t_ortak_dakika, y1, 'Color', [0.2 0.8 0.2], 'LineWidth', 0.8);
title('3 Ay Önceki Ham Sinyal (Sakin Yer Kabuğu - Baseline)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Genlik', 'FontSize', 11, 'FontWeight', 'bold');
grid on;
xlim([0 30]);

% --- 2. 3 GÜN ÖNCE (Öncü Evre) ---
subplot(3,1,2);
plot(t_ortak_dakika, y2, 'Color', [0.2 0.2 0.8], 'LineWidth', 0.8);
title('3 Gün Önceki Ham Sinyal (Deprem Öncesi)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Genlik', 'FontSize', 11, 'FontWeight', 'bold');
grid on;
xlim([0 30]);

% --- 3. DEPREM ANI (Yıkıcı Enerji) ---
subplot(3,1,3);
plot(t_ortak_dakika, y3, 'Color', [0.8 0.1 0.1], 'LineWidth', 0.8);
hold on;
% Depremin istasyona ulaştığı 7. dakikayı kesik çizgiyle işaretleyelim
xline(7, 'k--', '01:17 UTC (Deprem Vuruş Anı)', 'LineWidth', 1.5, 'LabelVerticalAlignment', 'top', 'FontSize', 10, 'FontWeight', 'bold');
title('6 Şubat Deprem Anı Ham Sinyali (Mw 7.8)', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Zaman (Dakika) - Kayıtların Başlangıcından İtibaren', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Genlik', 'FontSize', 11, 'FontWeight', 'bold');
grid on;
xlim([0 30]);

disp('Ham işaretlerin kıyaslama grafiği ekranda!');

%% 9. BÜTÜNCÜL SPEKTRAL ANALİZ: FFT, FAZ VE GAUSS MODELLERİ
disp('FFT Genlik, Faz spektrumları ve Gauss modelleri hesaplanıyor...');

% --- 1. FFT HESAPLAMALARI ---
N = length(y3); 
f_fft = (0:(N/2)-1) * (fs / N); % Frekans ekseni (Sadece pozitif)

% Fourier Dönüşümleri
Y1 = fft(y1); Y2 = fft(y2); Y3 = fft(y3);

% Genlik Spektrumları (Uzunluğa göre normalize edilmiş)
Amp1 = abs(Y1(1:N/2)) / N * 2;
Amp2 = abs(Y2(1:N/2)) / N * 2;
Amp3 = abs(Y3(1:N/2)) / N * 2;

% Faz Spektrumları (Radyan cinsinden, -pi ile pi arası)
Phase1 = angle(Y1(1:N/2));
Phase2 = angle(Y2(1:N/2));
Phase3 = angle(Y3(1:N/2));

% --- 2. GAUSS EĞRİSİ UYDURMA (DÜZELTİLMİŞ) ---
% Sismik açıdan en kritik ve enerjinin yığıldığı 0.05 Hz ile 1.5 Hz arasına odaklanıyoruz
ilgi_alani = (f_fft >= 0.05) & (f_fft <= 1.5);

% X ekseni (Frekans) verisini al ve KESİNLİKLE sütun vektörü yap (:)
X_veri = f_fft(ilgi_alani);
X_veri = X_veri(:); 

% Y ekseni (Genlik) verilerini al ve KESİNLİKLE sütun vektörü yap (:)
Y_deprem = Amp3(ilgi_alani);
Y_deprem = Y_deprem(:);

Y_3gun = Amp2(ilgi_alani);
Y_3gun = Y_3gun(:);

% Sütun vektörleri hazır olduğuna göre şimdi güvenle Gauss modelini oturtabiliriz
gauss_deprem = fit(X_veri, Y_deprem, 'gauss1');
gauss_3gun   = fit(X_veri, Y_3gun, 'gauss1');
% --- 3. GÖRSELLEŞTİRME ---
figure('Name', 'Bütüncül Spektral Analiz', 'Color', 'w', 'Position', [50, 50, 1100, 900]);

% 1. GRAFİK: FFT Genlik Spektrumu
subplot(3,1,1);
loglog(f_fft, Amp1, 'Color', [0.2 0.8 0.2], 'LineWidth', 1); hold on;
loglog(f_fft, Amp2, 'Color', [0.2 0.2 0.8], 'LineWidth', 1.5);
loglog(f_fft, Amp3, 'Color', [0.8 0.1 0.1], 'LineWidth', 1.5);
title('Hızlı Fourier Dönüşümü (FFT) - Genlik Spektrumu |Y(f)|', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Genlik');
xlim([0.01 10]); grid on;
legend('3 Ay Önce', '3 Gün Önce', 'Deprem Anı', 'Location', 'southwest');

% 2. GRAFİK: Faz Spektrumu
subplot(3,1,2);
% Sismik faz çok karmaşıktır, görselliği bozmaması için çizgileri transparan yapıyoruz
semilogx(f_fft, Phase1, 'Color', [0.2 0.8 0.2 0.3]); hold on; 
semilogx(f_fft, Phase2, 'Color', [0.2 0.2 0.8 0.5]);
semilogx(f_fft, Phase3, 'Color', [0.8 0.1 0.1 0.8]);
title('Faz Spektrumu \angle Y(f)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Faz (Radyan)');
xlim([0.01 10]); ylim([-pi pi]);
yticks([-pi -pi/2 0 pi/2 pi]);
yticklabels({'-\pi', '-\pi/2', '0', '\pi/2', '\pi'});
grid on;

% 3. GRAFİK: Gauss Dönüşümü (Sürekli Spektral Kestirim)
subplot(3,1,3);
% Ham FFT verilerini transparan (soluk) çizdir
plot(f_odak, Amp3(ilgi_alani), 'Color', [0.8 0.1 0.1 0.3], 'LineWidth', 1, 'DisplayName', 'Deprem (Ham FFT)'); hold on;
plot(f_odak, Amp2(ilgi_alani), 'Color', [0.2 0.2 0.8 0.3], 'LineWidth', 1, 'DisplayName', '3 Gün Önce (Ham FFT)');

% Üzerlerine pürüzsüz Gauss modellerini kalın çizdir
h1 = plot(gauss_deprem, 'r'); set(h1, 'LineWidth', 2, 'DisplayName', 'Deprem (Gauss Modeli)');
h2 = plot(gauss_3gun, 'b');   set(h2, 'LineWidth', 2, 'DisplayName', '3 Gün Önce (Gauss Modeli)');

title('Kritik Frekans Bandında (0.05 - 1.5 Hz) Sürekli Gauss Modellemesi', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Frekans (Hz)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Genlik');
xlim([0.05 1.5]); grid on;
legend('Location', 'northeast');

disp('FFT, Faz ve Gauss grafikleri şov için hazır!');