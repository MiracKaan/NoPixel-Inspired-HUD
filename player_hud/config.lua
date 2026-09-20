Config = {}

Config.EnableStress = true -- Stres gostergesini acip kapatir

Config.Stress = {
    chance = 0.1, -- Ates ederken stres kazanma sansi (0.1 = %10)
    minForShaking = 50, -- Ekranda titreme/blur baslamasi icin minimum stres
    minSpeedForStress = 160, -- Kemer takiliyken stres baslangic hizi (km/h)
    minSpeedForStressUnbuckled = 80, -- Kemer TAKILI DEGILKEN stres baslangic hizi (km/h)
    whitelistedWeapons = { -- Stres VERMEYEN silahlar
        `weapon_petrolcan`,
        `weapon_hazardcan`,
        `weapon_fireextinguisher`,
    }
}

Config.UseQbxMedical = false
Config.CrashSpeedThreshold = 15.0
Config.BleedingHealthThreshold = 170

Config.HealingEvents = {
    "hospital:client:Revive",
    "hospital:client:HealInjuries",
    "hospital:client:TreatWounds",
    "esx_ambulancejob:revive",
    "QBCore:Client:OnPlayerLoaded"
}
