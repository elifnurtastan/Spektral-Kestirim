% Bu dosyanın adı basit_sac_oku.m olarak kaydedilmeli
function [t, y] = basit_sac_oku(dosya_adi)
    % SAC dosyasını okuma modunda aç 
    fid = fopen(dosya_adi, 'rb', 'ieee-le'); 
    
    % İlk 70 değer float32, sonraki 40 değer int32 formatındadır
    hdr_floats = fread(fid, 70, 'single');
    hdr_ints = fread(fid, 40, 'int32');
    
    % Mantık kontrolü
    nvhdr = hdr_ints(7); 
    if nvhdr < 0 || nvhdr > 20
        fclose(fid);
        fid = fopen(dosya_adi, 'rb', 'ieee-be'); 
        hdr_floats = fread(fid, 70, 'single');
        hdr_ints = fread(fid, 40, 'int32');
    end
    
    % Verinin başladığı yere git
    fseek(fid, 632, 'bof');
    
    % NPTS (Veri noktası sayısı)
    npts = hdr_ints(10);
    
    % Sismik veriyi oku
    y = fread(fid, npts, 'single');
    fclose(fid);
    
    % Zaman eksenini oluştur
    delta = hdr_floats(1);
    b = hdr_floats(6);
    t = b + (0:length(y)-1)' * delta;
end