%% 9. BÜTÜNCÜL SPEKTRAL ANALİZ: FFT, FAZ VE GAUSS MODELLERİ
disp('FFT Genlik, Faz spektrumları ve Gauss modelleri hesaplanıyor...');

% --- 1. FFT HESAPLAMALARI ---
N = length(y3); 
f_fft = (0:(N/2)-1) * (fs / N); 
Y1 = fft(y1); Y2 = fft(y2); Y3 = fft(y3);

% Genlik Spektrumları (Normalize)
Amp2 = abs(Y2(1:N/2)) / N * 2;
Amp3 = abs(Y3(1:N/2)) / N * 2;

% Faz Spektrumları (Radyan)
Phase2 = angle(Y2(1:N/2));
Phase3 = angle(Y3(1:N/2));

% --- 2. GAUSS EĞRİSİ UYDURMA ---
ilgi_alani = (f_fft >= 0.05) & (f_fft <= 1.5);
X_veri = f_fft(ilgi_alani); X_veri = X_veri(:); 

Y_deprem_raw = Amp3(ilgi_alani);
Y_deprem = Y_deprem_raw(:) / max(Y_deprem_raw); 

Y_3gun_raw = Amp2(ilgi_alani);
Y_3gun = Y_3gun_raw(:) / max(Y_3gun_raw);

opt = fitoptions('gauss1');
opt.StartPoint = [1, 0.15, 0.1]; 
opt.Lower      = [0.1, 0.01, 0.001]; 
opt.Upper      = [1.5, 1.0, 0.5];    
opt.Robust     = 'LAR';              

try
    gauss_deprem = fit(X_veri, Y_deprem, 'gauss1', opt);
    gauss_3gun   = fit(X_veri, Y_3gun, 'gauss1', opt);
    disp('Gauss modelleri başarıyla oluşturuldu.');
catch ME
    warning('Gauss uydurma başarısız: %s', ME.message);
end

% --- 3. GÖRSELLEŞTİRME (EKRANLAR VE GRAFİKLER) ---
figure('Name', 'Bütüncül Spektral Analiz', 'Color', 'w', 'Position', [100, 100, 1000, 800]);

% --- Üst Grafik: Genlik Spektrumu ---
subplot(3,1,1);
plot(f_fft, Amp2, 'b', 'DisplayName', '3 Gün Önce'); hold on;
plot(f_fft, Amp3, 'r', 'DisplayName', 'Deprem Günü');
title('FFT Genlik Spektrumu (Ham Veri)', 'FontSize', 11);
xlabel('Frekans (Hz)'); ylabel('Genlik');
xlim([0 2]); grid on; legend;

% --- Orta Grafik: Faz Spektrumu ---
subplot(3,1,2);
plot(f_fft, Phase2, 'b', 'DisplayName', '3 Gün Önce'); hold on;
plot(f_fft, Phase3, 'r', 'DisplayName', 'Deprem Günü');
title('Faz Spektrumu (Radyan)', 'FontSize', 11);
xlabel('Frekans (Hz)'); ylabel('Faz');
xlim([0 2]); grid on; legend;

% --- Alt Grafik: Gauss Modellemesi ---
subplot(3,1,3);
hold on;
% Veri noktaları
plot(X_veri, Y_deprem, 'ro', 'MarkerSize', 3, 'DisplayName', 'Deprem (Nokta)');
plot(X_veri, Y_3gun, 'bo', 'MarkerSize', 3, 'DisplayName', '3 Gün Önce (Nokta)');

% Modelleri çizdir (Eğer hata almadıysa)
if exist('gauss_deprem', 'var')
    p1 = plot(gauss_deprem, 'r'); 
    set(p1, 'LineWidth', 2, 'DisplayName', 'Deprem Gauss Fit');
end
if exist('gauss_3gun', 'var')
    p2 = plot(gauss_3gun, 'b');   
    set(p2, 'LineWidth', 2, 'DisplayName', '3 Gün Önce Gauss Fit');
end

title('0.05 - 1.5 Hz Aralığında Normalize Gauss Modelleri', 'FontWeight', 'bold');
xlabel('Frekans (Hz)'); ylabel('Normalize Genlik');
xlim([0.05 1.5]); grid on;
legend('Location', 'northeast');
hold off;