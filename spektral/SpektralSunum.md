---
marp: true
theme: default
---

# Spektral Kestirim Yöntemleri: Periodogram ve Welch Yöntemleri

**Hazırlayan:** Elifnur Taştan

---

## 1. Giriş: Spektral Kestirim Nedir?
* **Tanım:** Zaman uzayındaki bir sinyalin güç dağılımının frekans bileşenlerine ayrıştırılmasıdır.
* **Temel Kavram:** Güç Spektral Yoğunluğu (Power Spectral Density - PSD).
* **Amaç:** * Sinyal içindeki baskın frekansları belirlemek.
    * Gürültü analizi yapmak.
    * Sinyalin enerji dağılımını anlamak.

---

## 2. Yöntemlerin Sınıflandırılması
Spektral kestirim yöntemleri iki ana kategoriye ayrılır:
1. **Parametrik Olmayan (Klasik) Yöntemler:** Fourier Dönüşümü temellidir. Sinyal modeli hakkında ön bilgi gerektirmez.
   * *Örnekler:* Periodogram, Bartlett, Welch.
2. **Parametrik Yöntemler:** Sinyalin belirli bir matematiksel modelden (AR, MA, ARMA) üretildiğini varsayar.

---

## 3. Periodogram Yöntemi
Periodogram, bir sinyalin PSD'sini tahmin etmek için kullanılan en temel parametrik olmayan yöntemdir. $N$ örnekli bir $x[n]$ sinyali için matematiksel model:

$$P_{xx}(f) = \frac{1}{N} \left| \sum_{n=0}^{N-1} x[n] e^{-j2\pi fn} \right|^2$$

**Parametreler:**
* $N$: Toplam örnek sayısı.
* $x[n]$: Ayrık zamanlı sinyal dizisi.
* $f$: Normalize edilmiş frekans.

---

## 4. Periodogramın Sınırları
* **Yüksek Varyans:** Veri sayısı artsa bile kestirimin varyansı düşmez (tutarsız kestirici).
* **Spektral Sızıntı (Spectral Leakage):** Sinyalin sonlu bir pencerede kesilmesi nedeniyle yan loblar oluşur.
* **Gürültü Hassasiyeti:** Rastgele gürültüye karşı çok hassastır ve pürüzlü bir spektrum üretir.

---

## 5. Welch Yöntemi (Modifiye Periodogram)
Welch yöntemi, periodogramın varyansını azaltmak için veriyi bölümlere ayırır ve ortalama alır.

**Temel Aşamalar:**
1. Veriyi örtüşen (overlapping) parçalara bölmek.
2. Her parçayı bir pencere fonksiyonu ile çarpmak.
3. Her parçanın periodogramını hesaplayıp ortalamasını almak.

---

## 6. Welch Yöntemi: Matematiksel Model I
Sinyal, her biri $M$ uzunluğunda $K$ adet parçaya bölünür. $i$. parça şu şekilde tanımlanır:

$$x_i[n] = x[n + iD], \quad 0 \le n \le M-1$$

**Parametreler:**
* $M$: Bölüt uzunluğu.
* $D$: Kaydırma miktarı (Örn: $D = M/2$ ise %50 örtüşme).
* $K$: Toplam parça sayısı.

---

## 7. Welch Yöntemi: Matematiksel Model II
Her parça için modifiye periodogram $P_i(f)$ hesaplanır:

$$P_i(f) = \frac{1}{MU} \left| \sum_{n=0}^{M-1} x_i[n] w[n] e^{-j2\pi fn} \right|^2$$

Burada $w[n]$ pencere fonksiyonu, $U$ ise pencere normalizasyon faktörüdür:
$$U = \frac{1}{M} \sum_{n=0}^{M-1} |w[n]|^2$$

---

## 8. Welch Yöntemi: Sonuç Kestirimi
Nihai Welch spektral kestirimi, tüm parçaların ortalaması alınarak bulunur:

$$P_{Welch}(f) = \frac{1}{K} \sum_{i=0}^{K-1} P_i(f)$$

Bu işlem varyansı $K$ kat oranında azaltarak daha pürüzsüz bir spektrum sağlar.

---

## 9. Karşılaştırma ve Parametre Etkisi
| Özellik | Periodogram | Welch |
| :--- | :--- | :--- |
| **Varyans** | Yüksek (Pürüzlü) | Düşük (Pürüzsüz) |
| **Çözünürlük** | Maksimum | Düşük (Pencereye bağlı) |
| **Tutarlılık** | Tutarsız | Tutarlı |

---

## 10. Görsel Özet ve İnfografik Analizi

![Spektral Kestirim Yöntemleri İnfografiği](indir.png)

---

## 11. Sonuç
* **Periodogram**, kısa veri setlerinde yüksek frekans çözünürlüğü sağlar ancak gürültülüdür.
* **Welch**, frekans çözünürlüğünden bir miktar ödün vererek daha güvenilir ve kararlı bir güç tahmini sunar. Modern uygulamalarda standart olarak kabul edilir.