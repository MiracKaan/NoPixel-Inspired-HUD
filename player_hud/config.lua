Config = {}

-- qbx_medical veya gelişmiş sağlık scriptleri entegrasyonu
-- Eğer true ise, kanama ve kırık durumlarını qbx_medical'in statebag/export'larından (veya benzeri bir scriptten) almaya çalışır.
Config.UseQbxMedical = false

-- Kaza anında kemik kırılmasını tetikleyecek hız düşüşü eşiği (m/s)
-- (Eğer qbx_medical kendi kırık sistemini kullanıyorsa bu değer yedek olarak kalır)
Config.CrashSpeedThreshold = 15.0

-- Otomatik kanamanın başlayacağı can seviyesi
-- (Eğer qbx_medical aktifse, kanama verisi direkt scriptten çekilir. Bu değer yedek (fallback) içindir.)
Config.BleedingHealthThreshold = 140

-- Kırık ve kanamanın otomatik sıfırlanacağı (iyileşeceği) event'ler
-- /revive atıldığında, hastanede tedavi olunduğunda veya oyuna ilk girildiğinde buradaki eventler çalışır.
Config.HealingEvents = {
    "hospital:client:Revive",
    "hospital:client:HealInjuries",
    "hospital:client:TreatWounds",
    "esx_ambulancejob:revive",
    "QBCore:Client:OnPlayerLoaded"
}
