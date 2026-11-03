%% 9. BÜTÜNCÜL SPEKTRAL ANALİZ: FFT, FAZ VE GAUSS MODELLERİ
disp('FFT Genlik, Faz spektrumları ve Gauss modelleri hesaplanıyor...');

% --- 1. FFT HESAPLAMALARI ---
N = length(y3); 
f_fft = (0:(N/2)-1) * (fs / N); 
Y1 = fft(y1); Y2 = fft(y2); Y3 = fft(y3);

% Genlik Spektrumları (Normalize edilmiş)
Amp1 = abs(Y1(1:N/2)) / N * 2;
Amp2 = abs(Y2(1:N/2)) / N * 2;
Amp3 = abs(Y3(1:N/2)) / N * 2;

% Faz Spektrumları
Phase1 = angle(Y1(1:N/2));
Phase2 = angle(Y2(1:N/2));
Phase3 = angle(Y3(1:N/2));

% --- 2. GAUSS EĞRİSİ UYDURMA (HATA DÜZELTME VE OPTİMİZASYON) ---
% Kritik bant: 0.05 - 1.5 Hz
ilgi_alani = (f_fft >= 0.05) & (f_fft <= 1.5);
X_veri = f_fft(ilgi_alani);
X_veri = X_veri(:); 

% Sayısal kararlılık için veriyi normalize ediyoruz (0-1 arasına çekiyoruz)
% Orijinal genlikler çok yüksek olduğu için (10^13 gibi) MATLAB 'Inf' hatası veriyor.
Y_deprem_raw = Amp3(ilgi_alani);
Y_deprem = Y_deprem_raw(:) / max(Y_deprem_raw); % Max değer 1 olacak şekilde oranla

Y_3gun_raw = Amp2(ilgi_alani);
Y_3gun = Y_3gun_raw(:) / max(Y_3gun_raw);

% Başlangıç tahminleri (StartPoint) ekleyerek algoritmanın sapmasını engelliyoruz
% [Genlik, Merkez, Genişlik]
start_point = [1, 0.1, 0.05]; 

try
    gauss_deprem = fit(X_veri, Y_deprem, 'gauss1', 'StartPoint', start_point);
    gauss_3gun   = fit(X_veri, Y_3gun, 'gauss1', 'StartPoint', start_point);
catch ME
    warning('Gauss uydurma sırasında hata: %s. Veriler çok gürültülü olabilir.', ME.message);
end

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
semilogx(f_fft, Phase1, 'Color', [0.2 0.8 0.2 0.3]); hold on; 
semilogx(f_fft, Phase2, 'Color', [0.2 0.2 0.8 0.5]);
semilogx(f_fft, Phase3, 'Color', [0.8 0.1 0.1 0.8]);
title('Faz Spektrumu \angle Y(f)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Faz (Radyan)');
xlim([0.01 10]); ylim([-pi pi]);
yticks([-pi -pi/2 0 pi/2 pi]);
yticklabels({'-\pi', '-\pi/2', '0', '\pi/2', '\pi'});
grid on;

% 3. GRAFİK: Gauss Dönüşümü (Normalize Edilmiş Kıyaslama)
subplot(3,1,3);
% Ham verileri çizdirirken tekrar eski ölçeğine döndürebiliriz veya 
% görsel kıyaslama için normalize kalsın:
p1 = plot(X_veri, Y_deprem, 'r.', 'MarkerSize', 8, 'DisplayName', 'Deprem (Ham)'); hold on;
p2 = plot(X_veri, Y_3gun, 'b.', 'MarkerSize', 8, 'DisplayName', '3 Gün Önce (Ham)');
plot(gauss_deprem, 'r'); 
plot(gauss_3gun, 'b');

title('Kritik Bandında (0.05 - 1.5 Hz) Normalize Gauss Modellemesi', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Frekans (Hz)');
ylabel('Normalize Genlik');
xlim([0.05 1.5]); grid on;
legend('Location', 'northeast');

disp('FFT, Faz ve Gauss grafikleri başarıyla oluşturuldu!');