%% 0. TEMİZLİK VE BAŞLANGIÇ
close all; % Açık olan eski pencereleri kapatır
clc;
disp('Gauss modellemesi çıkarıldı. Tüm veriler baştan işleniyor, lütfen bekleyin...');

%% 1. VERİLERİ OKUMA VE ÖN İŞLEME
% Verileri oku
[t1, y1_raw] = basit_sac_oku(dosya_3ay);
[t2, y2_raw] = basit_sac_oku(dosya_3gun);
[t_1g, y_1g_raw] = basit_sac_oku(dosya_1gun); 
[t3, y3_raw] = basit_sac_oku(dosya_deprem);

% MATEMATİKSEL ÇÖKMELERİ ÖNLEMEK İÇİN VERİLERİ 'DOUBLE' FORMATINA ÇEVİR
y1 = double(y1_raw); 
y2 = double(y2_raw); 
y_1g = double(y_1g_raw); 
y3 = double(y3_raw);

% DC Ofset ve Trend Temizliği
y1 = detrend(y1 - mean(y1));
y2 = detrend(y2 - mean(y2));
y_1g = detrend(y_1g - mean(y_1g));
y3 = detrend(y3 - mean(y3));

fs = round(1 / (t3(2) - t3(1))); 

% HER SİNYAL İÇİN ÖZEL ZAMAN EKSENİ (Uzunluk uyuşmazlığı hatasını KESER)
t_dak_1 = (0:length(y1)-1) / (fs * 60);
t_dak_2 = (0:length(y2)-1) / (fs * 60);
t_dak_1g = (0:length(y_1g)-1) / (fs * 60);
t_dak_3 = (0:length(y3)-1) / (fs * 60);

%% 2. WELCH PSD ANALİZİ (Pencere 1)
disp('1/5: Welch PSD grafiği çiziliyor...');
window_sec = 40;
nperseg = window_sec * fs;
noverlap = floor(nperseg/2);

[pxx_3ay, f_w] = pwelch(y1, hamming(nperseg), noverlap, nperseg, fs);
[pxx_3gun, ~] = pwelch(y2, hamming(nperseg), noverlap, nperseg, fs);
[pxx_1gun, ~] = pwelch(y_1g, hamming(nperseg), noverlap, nperseg, fs);
[pxx_deprem, ~] = pwelch(y3, hamming(nperseg), noverlap, nperseg, fs);

figure('Name', 'Pencere 1: Welch PSD Kıyaslaması', 'Color', 'w', 'Position', [50, 50, 800, 500]);
loglog(f_w, pxx_3ay, 'Color', [0.2 0.8 0.2], 'LineWidth', 1); hold on;
loglog(f_w, pxx_3gun, 'Color', [0.2 0.2 0.8], 'LineWidth', 1);
loglog(f_w, pxx_1gun, 'Color', [0.8 0.5 0.1], 'LineWidth', 1);
loglog(f_w, pxx_deprem, 'Color', [0.8 0.1 0.1], 'LineWidth', 2);
title('Welch Güç Spektral Yoğunluğu', 'FontWeight', 'bold');
xlabel('Frekans (Hz)'); ylabel('Güç (V^2/Hz)'); xlim([0.05 10]); grid on;
legend('3 Ay Önce', '3 Gün Önce', '1 Gün Önce', 'Deprem Anı');

%% 3. HAM SİNYAL KIYASLAMASI (Pencere 2)
disp('2/5: Zaman serileri çiziliyor...');
figure('Name', 'Pencere 2: Ham Sinyal Zaman Serisi', 'Color', 'w', 'Position', [100, 100, 800, 600]);
subplot(4,1,1); plot(t_dak_1, y1, 'g'); title('3 Ay Önce'); grid on;
subplot(4,1,2); plot(t_dak_2, y2, 'b'); title('3 Gün Önce'); grid on;
subplot(4,1,3); plot(t_dak_1g, y_1g, 'Color', [0.8 0.5 0.1]); title('1 Gün Önce'); grid on;
subplot(4,1,4); plot(t_dak_3, y3, 'r'); title('Deprem Anı'); grid on;
xlabel('Zaman (Dakika)');

%% 4. SPEKTROGRAM ANALİZİ (Pencere 3)
disp('3/5: Spektrogram oluşturuluyor...');
figure('Name', 'Pencere 3: Spektrogram Analizi', 'Color', 'w', 'Position', [150, 150, 800, 500]);
pencere_saniye = 15;
nperseg_spec = pencere_saniye * fs;
[S, F_spec, T_spec, P] = spectrogram(y3, hamming(nperseg_spec), round(nperseg_spec*0.9), 1024, fs);
surf(T_spec/60, F_spec, 10*log10(P), 'EdgeColor', 'none');
axis xy; axis tight; view(0,90); colormap(jet); colorbar;
ylim([0 5]); title('Deprem Anı Spektrogram (Zaman-Frekans)', 'FontWeight', 'bold');
xlabel('Zaman (Dakika)'); ylabel('Frekans (Hz)');

%% 5. FFT ANALİZİ (Pencere 4 - SADECE FFT)
disp('4/5: FFT hesaplanıyor...');
% Sinyal uzunluklarını ayrı ayrı alıyoruz ki boyut uyuşmazlığı çıkmasın
N3 = length(y3); yarim_N3 = floor(N3/2);
N2 = length(y2); yarim_N2 = floor(N2/2);

f_fft3 = (0:yarim_N3-1) * (fs / N3);
f_fft2 = (0:yarim_N2-1) * (fs / N2);

Amp3 = abs(fft(y3)); Amp3 = Amp3(1:yarim_N3) / N3 * 2;
Amp2 = abs(fft(y2)); Amp2 = Amp2(1:yarim_N2) / N2 * 2;

figure('Name', 'Pencere 4: FFT Genlik Spektrumu', 'Color', 'w', 'Position', [200, 200, 800, 400]);
loglog(f_fft2, Amp2, 'b', 'LineWidth', 1.5); hold on;
loglog(f_fft3, Amp3, 'r', 'LineWidth', 1.5);
title('Hızlı Fourier Dönüşümü (FFT) - Genlik Spektrumu', 'FontWeight', 'bold'); 
xlabel('Frekans (Hz)'); ylabel('Genlik');
xlim([0.01 10]); grid on;
legend('3 Gün Önce', 'Deprem Anı');

%% 6. STFT ANALİZİ (Pencere 5)
disp('5/5: STFT hesaplanıyor...');
window_len = round(fs * 20);

try
    [s_stft, f_stft, t_stft] = stft(y3, fs, 'Window', hamming(window_len), 'OverlapLength', round(window_len*0.75));

    figure('Name', 'Pencere 5: STFT Analizi', 'Color', 'w', 'Position', [250, 250, 1000, 600]);
    subplot(2,1,1);
    imagesc(t_stft/60, f_stft, abs(s_stft));
    axis xy; colormap(inferno); colorbar; ylim([0 5]);
    title('STFT Genlik Isı Haritası', 'FontWeight', 'bold');
    ylabel('Frekans (Hz)'); xlabel('Zaman (Dakika)');

    subplot(2,1,2);
    mesh(t_stft/60, f_stft(f_stft<=5), abs(s_stft(f_stft<=5, :)));
    view(-35, 45); colormap(jet);
    title('STFT 3D Enerji Yüzeyi', 'FontWeight', 'bold');
    xlabel('Zaman (Dakika)'); ylabel('Frekans (Hz)'); zlabel('Genlik');
    disp('Bütün grafikler başarıyla ekrana yansıtıldı!');
catch ME
    disp('Uyarı: STFT grafiği çizilirken bir hata oluştu (Sürüm uyuşmazlığı olabilir).');
    disp(ME.message);
end

%% 7. SÜREKLİ DALGACIK DÖNÜŞÜMÜ (CWT - Continuous Wavelet Transform)
disp('6/6: Sürekli Dalgacık Dönüşümü (CWT) hesaplanıyor. Lütfen bekleyin...');
disp('Not: Bu işlem STFT''den daha detaylı olduğu için birkaç saniye sürebilir.');

try
    % Sismik enerjinin asıl yığıldığı 0.05 Hz ile 5 Hz arasına odaklanıyoruz.
    % 'amor' -> Analitik Morlet dalgacığı (Deprem sinyalleri için en iyi şablondur)
    frekans_limiti = [0.05 5];
    
    [wt_deprem, f_cwt] = cwt(y3, 'amor', fs, 'FrequencyLimits', frekans_limiti);
    [wt_3un, ~]       = cwt(y_1g, 'amor', fs, 'FrequencyLimits', frekans_limiti);

    % Zaman eksenlerini tekrar hesaplayalım (Dakika cinsinden)
    t_dak_3 = (0:length(y3)-1) / (fs * 60);
    t_dak_2 = (0:length(y2)-1) / (fs * 60);

    % CWT İçin Yeni Bir Pencere Açıyoruz
    figure('Name', 'Pencere 6: CWT Dalgacık Dönüşümü', 'Color', 'w', 'Position', [300, 100, 1000, 700]);

    % --- 1. GRAFİK: 3 GÜN ÖNCE (ÖNCÜ EVRE) ---
    subplot(2,1,1);
    % Mutlak değeri (abs) alınarak genlik matrisi ısı haritasına dökülür
    imagesc(t_dak_2, f_cwt, abs(wt_3gun));
    axis xy; colormap(jet);
    title('3 Gün Önce (Öncü Evre) - Yüksek Çözünürlüklü CWT', 'FontWeight', 'bold', 'FontSize', 12);
    ylabel('Frekans (Hz)', 'FontWeight', 'bold'); 
    xlabel('Zaman (Dakika)', 'FontWeight', 'bold');
    c1 = colorbar; c1.Label.String = 'Dalgacık Genliği';
    
    % --- 2. GRAFİK: 6 ŞUBAT DEPREM ANI ---
    subplot(2,1,2);
    imagesc(t_dak_3, f_cwt, abs(wt_deprem));
    axis xy; colormap(jet);
    title('6 Şubat Deprem Anı - Yüksek Çözünürlüklü CWT', 'FontWeight', 'bold', 'FontSize', 12);
    ylabel('Frekans (Hz)', 'FontWeight', 'bold'); 
    xlabel('Zaman (Dakika)', 'FontWeight', 'bold');
    c2 = colorbar; c2.Label.String = 'Dalgacık Genliği';
    
    % Depremin istasyona ulaştığı 7. dakikaya dikey referans çizgisi
    hold on;
    xline(7, 'w--', 'P-Dalgası İlk Vuruş', 'LineWidth', 2, 'LabelVerticalAlignment', 'top', 'FontSize', 11, 'FontWeight', 'bold');

    disp('Harika! CWT Analizi Pencere 6 olarak ekrana yansıtıldı.');

catch ME
    disp('DİKKAT: CWT grafiği çizilemedi!');
    disp(['Hata Detayı: ', ME.message]);
    disp('Çözüm: Bu analizi yapabilmek için MATLAB "Wavelet Toolbox" eklentisinin bilgisayarında yüklü olması gerekmektedir.');
end

%% 8. ÇAPRAZ KORELASYON VE ŞABLON EŞLEŞTİRME (Template Matching)
disp('Çapraz Korelasyon hesaplanıyor (Gizli öncü deprem taraması)...');

try
    % 1. Şablon (Template) Oluşturma: Depremin vurduğu o ilk anı kesip alıyoruz.
    % Deprem yaklaşık 7. dakikada vuruyordu. 6.9 ile 7.1 dakikalar arasını şablon yapalım.
    baslangic_idx = round(6.9 * 60 * fs);
    bitis_idx = round(7.1 * 60 * fs);
    sablon = y3(baslangic_idx:bitis_idx);
    
    % Şablonun zaman eksenini saniye olarak oluşturalım
    t_sablon = (0:length(sablon)-1) / fs;

    % 2. Normalize Çapraz Korelasyon
    % Şablonu, 1 GÜN ÖNCEKİ veri (y_1g) üzerinde gezdirip benzerlik arıyoruz
    % 'coeff' parametresi, sonucu -1 (tam tersi) ile +1 (birebir aynı) arasına çeker.
    [korelasyon, gecikme] = xcorr(y_1g, sablon, 'coeff');
    
    % Gecikme (Lag) değerlerini dakikaya çevirelim
    t_korelasyon_dakika = gecikme / (fs * 60);
    
    % Sadece pozitif zaman gecikmelerini (ileri yönlü tarama) alalım
    pozitif_idx = gecikme >= 0;
    t_plot = t_korelasyon_dakika(pozitif_idx);
    kor_plot = korelasyon(pozitif_idx);

    % 3. Görselleştirme
    figure('Name', 'Çapraz Korelasyon: Öncü Şok Taraması', 'Color', 'w', 'Position', [350, 150, 1000, 600]);
    
    % Üst Grafik: Kullanılan Şablon (Depremin P-Dalgası İmzası)
    subplot(2,1,1);
    plot(t_sablon, sablon, 'r', 'LineWidth', 1);
    title('Arama Şablonu: 6 Şubat Depremi İlk P-Dalgası İmzası', 'FontWeight', 'bold', 'FontSize', 12);
    xlabel('Zaman (Saniye)'); ylabel('Genlik');
    grid on;
    
    % Alt Grafik: 1 Gün Önceki Veride Benzerlik Taraması Sonucu
    subplot(2,1,2);
    plot(t_plot, kor_plot, 'b', 'LineWidth', 1);
    hold on;
    
    % Anomali Eşiği (Örneğin %40 benzerlik eşiği)
    yline(0.4, 'r--', '%40 Benzerlik Eşiği (Dikkat!)', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');
    
    title('1 Gün Önceki (5 Şubat) Sismik Veride Şablon Eşleştirme', 'FontWeight', 'bold', 'FontSize', 12);
    xlabel('Zaman (Dakika) - 5 Şubat Kaydı Boyunca'); 
    ylabel('Korelasyon Katsayısı (Benzerlik)');
    ylim([-0.2 0.6]); % Genellikle sismolojide 0.4 - 0.5 arası gizli deprem sayılır
    grid on;

    disp('Çapraz Korelasyon başarıyla tamamlandı ve grafiğe döküldü.');

catch ME
    disp('Korelasyon analizi sırasında bir hata oluştu:');
    disp(ME.message);
end

%% 9. HILBERT DÖNÜŞÜMÜ VE SİSMİK ENERJİ ZARFI (Envelope Analysis)
disp('7/7: Hilbert Dönüşümü ve Enerji Zarfı hesaplanıyor...');

try
    % Zaman eksenini dakika olarak oluştur (y3 ve fs değişkenleri önceki kodlardan geliyor)
    t_dak_3 = (0:length(y3)-1) / (fs * 60);

    % 1. HILBERT DÖNÜŞÜMÜ: Sinyali karmaşık (analitik) düzleme taşır
    analitik_sinyal = hilbert(y3);

    % 2. ZARF (ENVELOPE) ÇIKARMA: Analitik sinyalin mutlak değeri bize dış sınırları verir
    zarf = abs(analitik_sinyal);

    % 3. YUMUŞATMA (Opsiyonel ama çok şık durur)
    % Zarfın üzerindeki ufak pürüzleri alıp ana enerji dağını görmek için 
    % 2 saniyelik (2*fs) bir hareketli ortalama (moving average) uyguluyoruz.
    pencere_boyu = round(fs * 2); 
    yumusak_zarf = movmean(zarf, pencere_boyu);

    % --- GÖRSELLEŞTİRME ---
    figure('Name', 'Pencere 7: Hilbert Dönüşümü ve Enerji Zarfı', 'Color', 'w', 'Position', [400, 200, 1000, 500]);

    % Arka plana ham sinyali soluk gri renkte çizdiriyoruz
    plot(t_dak_3, y3, 'Color', [0.7 0.7 0.7 0.6], 'LineWidth', 0.5, 'DisplayName', 'Ham Sismik Titreşim');
    hold on;

    % Üzerine şemsiye gibi saran kırmızı enerji zarfını çizdiriyoruz
    plot(t_dak_3, yumusak_zarf, 'r', 'LineWidth', 2.5, 'DisplayName', 'Enerji Zarfı (Hilbert)');
    
    % Alt sınırı da simetrik olarak çizdirelim ki tam bir kılıf (envelope) olsun
    plot(t_dak_3, -yumusak_zarf, 'r', 'LineWidth', 2.5, 'HandleVisibility', 'off');

    % Deprem anını işaretle (7. dakika civarı)
    xline(7, 'k--', 'P-Dalgası Vuruşu', 'LineWidth', 2, 'LabelVerticalAlignment', 'top', 'FontSize', 11, 'FontWeight', 'bold');

    % Eksenler ve Etiketler
    title('6 Şubat Depremi: Hilbert Dönüşümü ile Sismik Enerji Zarfı Çıkarımı', 'FontWeight', 'bold', 'FontSize', 13);
    xlabel('Zaman (Dakika)', 'FontWeight', 'bold');
    ylabel('Genlik (Enerji Sınırı)', 'FontWeight', 'bold');
    
    % Grafiği sıkılaştır ve makyajla
    xlim([0 30]);
    ylim([-max(zarf)*1.1, max(zarf)*1.1]);
    grid on;
    legend('Location', 'northeast', 'FontSize', 11);

    disp('Hilbert Dönüşümü başarıyla tamamlandı ve Pencere 7 olarak yansıtıldı.');

catch ME
    disp('Hilbert Dönüşümü sırasında bir hata oluştu:');
    disp(ME.message);
end

%% 10. İSTATİSTİKSEL SİNYAL KARMAŞIKLIĞI (Entropi ve Fraktal Boyut)
disp('8/8: Entropi ve Fraktal Boyut (Katz) hesaplanıyor...');

try
    % Kayan pencere (Sliding Window) parametreleri
    % Sinyali 10 saniyelik parçalara bölerek zaman içindeki değişimi izleyeceğiz
    pencere_saniye = 10; 
    pencere_ornek = round(pencere_saniye * fs);
    adim_ornek = round(pencere_ornek / 2); % %50 örtüşme (overlap) ile daha yumuşak grafik
    
    N3 = length(y3);     % Deprem Anı
    N1g = length(y_1g);  % 1 Gün Önce (Kıyaslama için)
    
    % Çıktıları toplayacağımız boş diziler
    zaman_vektoru_3 = []; entropi_3 = []; fraktal_3 = [];
    zaman_vektoru_1g = []; entropi_1g = []; fraktal_1g = [];
    
    % --- 1 GÜN ÖNCE İÇİN HESAPLAMA (Sakin Referans Hattı) ---
    for i = 1:adim_ornek:(N1g - pencere_ornek)
        pencere = y_1g(i : i + pencere_ornek - 1);
        
        % 1. Shannon Entropisi Hesabı (Kaos Seviyesi)
        [frekanslar, ~] = histcounts(pencere, 50); % Veriyi 50 kutuya böl
        olasilik = frekanslar / sum(frekanslar);
        olasilik(olasilik == 0) = []; % Log(0) hatasını matematiksel olarak yut
        E = -sum(olasilik .* log2(olasilik));
        
        % 2. Katz Fraktal Boyutu (Pürüzlülük/Kırılganlık Seviyesi)
        L = sum(abs(diff(pencere))); % Eğrinin toplam yürüme uzunluğu
        a = L / (length(pencere)-1); % Ortalama adım mesafesi
        d = max(abs(pencere - pencere(1))); % Maksimum sapma mesafesi
        
        % 0'a bölünme (Inf) hatasını önleyen koruma bloğu
        if d == 0 || a == 0; FD = 1.0; else; FD = log10(L/a) / log10(d/a); end
        
        entropi_1g(end+1) = E;
        fraktal_1g(end+1) = FD;
        zaman_vektoru_1g(end+1) = (i + pencere_ornek/2) / (fs * 60); % Dakika cinsinden
    end
    
    % --- 6 ŞUBAT DEPREM ANI İÇİN HESAPLAMA ---
    for i = 1:adim_ornek:(N3 - pencere_ornek)
        pencere = y3(i : i + pencere_ornek - 1);
        
        % Shannon Entropisi
        [frekanslar, ~] = histcounts(pencere, 50);
        olasilik = frekanslar / sum(frekanslar);
        olasilik(olasilik == 0) = [];
        E = -sum(olasilik .* log2(olasilik));
        
        % Katz Fraktal Boyutu
        L = sum(abs(diff(pencere))); 
        a = L / (length(pencere)-1); 
        d = max(abs(pencere - pencere(1))); 
        if d == 0 || a == 0; FD = 1.0; else; FD = log10(L/a) / log10(d/a); end
        
        entropi_3(end+1) = E;
        fraktal_3(end+1) = FD;
        zaman_vektoru_3(end+1) = (i + pencere_ornek/2) / (fs * 60);
    end

    % --- GÖRSELLEŞTİRME ---
    figure('Name', 'Pencere 8: Entropi ve Fraktal Boyut Analizi', 'Color', 'w', 'Position', [450, 250, 1000, 700]);
    
    % 1. ALT GRAFİK: Shannon Entropisi
    subplot(2,1,1);
    plot(zaman_vektoru_1g, entropi_1g, 'Color', [0.2 0.5 0.8], 'LineWidth', 1.5, 'DisplayName', '1 Gün Önce (Sakin)');
    hold on;
    plot(zaman_vektoru_3, entropi_3, 'Color', [0.8 0.1 0.1], 'LineWidth', 2, 'DisplayName', 'Deprem Anı');
    xline(7, 'k--', 'Deprem Vuruşu', 'LineWidth', 2, 'HandleVisibility', 'off');
    
    title('Shannon Entropisi (Sinyal Kaosu ve Tahmin Edilemezlik)', 'FontWeight', 'bold', 'FontSize', 12);
    ylabel('Entropi (Bit)'); grid on; 
    legend('Location', 'northeast');
    xlim([0 30]);
    
    % 2. ALT GRAFİK: Katz Fraktal Boyutu
    subplot(2,1,2);
    plot(zaman_vektoru_1g, fraktal_1g, 'Color', [0.2 0.5 0.8], 'LineWidth', 1.5, 'DisplayName', '1 Gün Önce');
    hold on;
    plot(zaman_vektoru_3, fraktal_3, 'Color', [0.8 0.1 0.1], 'LineWidth', 2, 'DisplayName', 'Deprem Anı');
    xline(7, 'k--', 'Deprem Vuruşu', 'LineWidth', 2, 'HandleVisibility', 'off');
    
    title('Katz Fraktal Boyutu (Sinyal Pürüzlülüğü ve Kırılganlık)', 'FontWeight', 'bold', 'FontSize', 12);
    xlabel('Zaman (Dakika)'); ylabel('Fraktal Boyut (FD)'); grid on;
    xlim([0 30]);

    disp('Entropi ve Fraktal Boyut analizi başarıyla tamamlandı ve Pencere 8 olarak yansıtıldı.');

catch ME
    disp('Entropi hesaplaması sırasında bir hata oluştu:');
    disp(ME.message);
end
