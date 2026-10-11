# DX Media Player

V11 Audio Visual Experience: gerçek PCM ile Audio Orb, Particle Visualizer ve Spectrum Bars; Circular Spectrum varsayılanı, pause'da sabit kare ve yeni cleanup/regresyon düzeltmeleri. Güncel teslimat ve sınırlar: [V11 raporu](docs/AUDIO_VISUAL_V11_REPORT.md).

**DorukX — PLAY BEYOND LIMITS.** Windows için Python 3.11+, PySide6 ve libmpv tabanlı medya oynatıcı.

11 Ekim 2026 yeniden oluşturma sürümü. Bütün sohbetin gereksinimleri `docs/REBUILD_PLAN.md` içinde birleştirildi. Kaynaklar, SVG varlıkları, testler ve paketleme sistemi tekrar kuruldu. Güncel test ve teslimat durumu `docs/REBUILD_REPORT.md` içindedir; aşağıdaki eski sürüm notları tarihsel kayıt içerir.

## Çalıştırma

```powershell
python -m pip install -r requirements.txt
python main.py
# veya
python main.py "C:\Medya\Türkçe şarkı.mp4"
```

Yerel EXE: `build/DXMediaPlayer/DXMediaPlayer.exe`. **EXE'yi bütün paket klasörüyle birlikte tutun.** EXE paketinde FFmpeg, FFprobe ve libmpv bulunur. Kaynaktan çalıştırırken FFmpeg/FFprobe PATH üzerinde bulunmalı veya Ayarlar'dan seçilmelidir. Kurulum dosyası: `build/DXMediaPlayer-Setup.exe`.

Ayarlar, SQLite kütüphanesi, kapaklar ve loglar `%LOCALAPPDATA%\DX Media Player` içine yazılır. Açılışta klasör taraması ve AI model indirmesi yapılmaz.

## V2 özellikleri

- **Araçlar > DX Audio Visualizer:** Spectrum Analyzer, Audio Waveform, Circular Spectrum, Audio Pulse ve Stereo Channel Visualizer. DorukX/Okyanus/Neon/Orman temaları ve 30/60 FPS sınırı Ayarlar'da bulunur. Fullscreen Music Visualizer ayrıca Araçlar menüsündedir.
- **Video > DX Ambilight:** gerçek video kenar renkleri, uzamsal yumuşatma ve yumuşak renk geçişleri. Yoğunluk ve örnekleme genişliği Ayarlar'dan değişir. Tam ekranı destekler.
- **Smart Timeline Preview:** yerel, ileri sarılabilir videolarda fare konumuna bağlı kare ve zaman damgası. Çözünürlük, gecikme ve RAM önbellek sınırı Ayarlar'dadır. Önizleme zamanı yarım saniyeye yuvarlanır. Hover bitince işlem iptal edilir. Akışlarda otomatik kapalıdır.
- **Görünüm > DX Media Library:** açıkça izin verilen klasörleri arka planda tarar. SQLite, grid/liste, arama, kategoriler, sıralama, favoriler, konum hatırlama, video kapakları ve gömülü albüm kapakları. İzinli klasörler düğmesi tarama iznini kaldırır; mevcut kartlar korunur. Filmler kategorisi 40 dakika ve üzeri videoları kullanır; çevrim içi film tahmini yapılmaz. Oynatma listesini kaydetmek listeyi kütüphaneye de ekler.

### Gerçek veri ve mimari sınırları

libmpv ses çıkışını sürdürür. Seçili **yerel kaynak ses parçası** bağımsız FFmpeg `f32le`, 44.1 kHz stereo borusuyla çözümlenir. Zaman damgalı sınırlı tamponlardan 4096 örnekli Hann FFT ve 64 logaritmik bant hesaplanır. Seek eski tamponları geçersiz kılar; pause ve görünmez durumda analiz durur. Çizim 30/60 FPS ile sınırlanır. Rastgele ses hareketleri yoktur. **Bu ölçüm mpv EQ, normalizasyon, mute veya ses cihazı sonrasındaki çıkışı ölçmez.** Harici ses parçası ve ağ akışı analizi desteklenmez.

Ambilight, native mpv video yüzeyini ekran yakalama ile okumaz. Bağımsız FFmpeg çözümleyici oynatma zamanında en fazla 4 kare/sn örnekler, kareyi 32–160 px genişliğe indirir, dört kenarın ortalama rengini hesaplar. Uzamsal ortalama ve saydam gradyan yumuşak ışık yayılımı oluşturur; 30 FPS geçişler sadece bu gerçek renk hedefleri arasında gerçekleşir. **Kaynak renkleri mpv filtrelerini, döndürmeyi, ekrandaki altyazıyı veya HDR ton eşlemeyi içermez.** Ağ akışları için kapalıdır. Büyük 4K/uzun GOP dosyalarında bağımsız çözümleme ilave CPU yükü ve renk gecikmesi yaratabilir; bütün donanımlarda sıfır gecikme garantisi verilmez.

Önizleme ve Ambilight kendi süreç kayıtlarına ve çalışanlarına sahiptir. Tek son istek tutulur; eski hover/medya sonuçları uygulanmaz. Kapatmada alt süreçler sonlandırılır ve çalışanlar birleştirilir. Kütüphane taraması yalnızca seçilen köklerde kalır; dışarı yönelen sembolik bağlantı/junction dizinleri atlanır. SQLite bağlantıları işlem sonunda kapatılır.

Teknik kaynaklar: [mpv client API](https://github.com/mpv-player/mpv/blob/master/include/mpv/client.h), [mpv komutları ve screenshot-raw](https://mpv.io/manual/stable/), [FFmpeg belgeleri](https://ffmpeg.org/ffmpeg.html), [mpv Windows kurulum seçenekleri](https://mpv.io/installation/).

## Temel oynatıcı

Dosya/çoklu dosya/klasör/URL açma, drag-and-drop, M3U/M3U8/PLS okuma, M3U8 kaydetme, liste düzenleme, shuffle/repeat, hız, ses, parça seçimi, altyazı, screenshot, kare adımlama ve bölümler mevcuttur. Space/F/Esc/oklar/M/S/N/P/Ctrl+O/Ctrl+U/Ctrl+L/Ctrl+Shift+S kısayolları Ayarlar'daki JSON alanından değiştirilebilir.

FFmpeg dönüştürme, remux, ses çıkarma ve toplu dönüştürme arka planda çalışır. İlerleme FFmpeg zaman bilgisiyle hesaplanır. Hedef dosya zaten varsa yeni ad gerekir; geçici çıktı başarıyla bitince taşınır. Codec bulunabilirliği FFmpeg derlemesine bağlıdır. Eksik codec hatası gizlenmez.

Whisper altyazı kaynak Python sürümünde `pip install faster-whisper` sonrasında kullanılabilir. Model indirmek için arayüz onay ister. AI ayrı, iptal edilebilir süreçte çalışır. Yerel EXE çekirdek paketinde isteğe bağlı Whisper/CT2 çalışma zamanı paketlenmemiştir. DeepL çevirisi SRT üzerinden çalışır, gönderim öncesi onay ister; anahtar yalnızca oturumda tutulur. AI model transkripsiyonu ve gerçek DeepL çağrısı bu oturumda çalıştırılmadı.

Eklentiler ayrı süreçte çalışır; dizinde bulunmaları etkinleştirmez. Manifest API sürümü ve giriş yolu doğrulanır, etkinleştirmede kod çalıştırma uyarısı gösterilir. **Bu OS sandbox değildir.** `plugins/example_plugin` örneği yüklenebilir. Mevcut eklenti protokolü medya/oynatma olaylarını destekler; tam panel/menü/çeviri sağlayıcısı kayıt API'si ve etkinlik durumunun kalıcı yönetimi henüz uygulanmadı.

## Test ve derleme

```powershell
python -m pytest -q --junitxml=test-results.xml
python scripts/verify_playback.py
python scripts/verify_exe.py
powershell -ExecutionPolicy Bypass -File build.ps1
# veya build.bat; yalnızca EXE için build.ps1 -SkipInstaller
```

`docs/TEST_REPORT.md` sonuçları içerir. V8 sürümünde **67 otomatik test, 29 native oynatma kontrolü, 16 DPI/boyut senaryosu ve 9 EXE kontrolü geçti.** Test medyaları lavfi sine/testsrc ile yerel üretilir; dış medya indirilmez. Derleme çalışmaları OneDrive dışında `%LOCALAPPDATA%\DX Media Player Build` dizininde yapılır; paket proje `build` ve `dist` dizinlerine kopyalanır. Setup için Inno Setup 7/6 gerekir; derleyici yolu `INNO_SETUP_COMPILER` ile belirtilebilir.

## Premium UI V8

DorukX sarısı ve verilen koyu palet, logolu üst menü, iki satırlı medya çubuğu, büyük sarı SVG play/pause, gerçek mpv parça seçimleri ve isteğe bağlı medya bilgisi paneli eklendi. Video alanına çift tıklama fullscreen; sağ tık medya menüsü. Ses dosyalarında gömülü kapak/metadata, bulanık kapak arka planı ve gerçek PCM Circular Spectrum içeren Audio Mode otomatik açılır. Playlist arama, kapak/süre, aktif satır ve sürükleme sıralaması sunar. Ayrıntılar ve sınırlar: `docs/PREMIUM_UI.md`.

## DX Mini Terminal

Araçlar > DX Mini Terminal veya Ctrl+backtick ile açılır. Alt panel yüzdürülerek küçük pencere olarak kullanılabilir. Yukarı/aşağı komut geçmişi, Tab otomatik tamamlama sağlar. `help` bütün komutları listeler. Kullanım ve kayıt kuralları: `docs/MINI_TERMINAL.md`.

Komutlar mevcut libmpv denetleyicisine bağlıdır. `link name 1 "Örnek Video"` gibi tırnaklı Türkçe adlar desteklenir. Ayar/bağlantı değişiklikleri bellekte uygulanır; `save` kalıcı kaydeder. Uygulamayı kapatmak kaydedilmemiş konsol değişikliklerini kaydetmez. `reset` onay ister, konsol ayarlarını bellekte varsayılana çevirir; kalıcı kayıt yine `save` gerektirir. Konsol işletim sistemi komutlarını yürütmez.

## Teslimat sınırları

Bu sürüm dört V2 özelliğini, Mini Terminal'i ve çalışan oynatma çubuğunu sunar; ana metindeki bütün üretim gereksinimlerinin tamamlandığı iddia edilmez. İngilizce ana menü çevirisi vardır; ayrıntılı diyaloglar ve komut mesajları Türkçedir. Sistem temasını gerçek OS temasına bağlama, gelişmiş çok bantlı EQ, tam dönüşüm seçenekleri/preset arayüzü, kimlik bilgisi kasası ve eksiksiz plugin kayıt API'si ileride tamamlanmalıdır. Installer temiz VM üzerinde kurulup kaldırılmadı. Kişisel AppData kaldırmada korunur; installer içinden kişisel veri silme seçeneği yoktur. Uzun süreli 4K/HDR, DRM, canlı yayın, GPU matrisi ve yüksek hacimli kütüphane stres testleri yapılmadı.

Yerel EXE doğrulama amaçlıdır. Üçüncü taraf DLL'lerin yeniden dağıtım lisansları, tam karşılık gelen kaynaklar ve bildirimleri kamuya yayınlamadan önce tamamlanmalıdır; `docs/THIRD_PARTY_NOTICES.md` kaynak ve derleme bilgisini kaydeder.

V11.1 / V11.2: [embedded browser and playback controls](docs/WEB_FALLBACK_V11_2.md). HTTP/HTTPS web pages open inside DX Media Player; failed direct-media loads fall back once to the original page.
