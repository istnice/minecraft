

i_mehl:
  type: item
  material: sugar
  display name: Mehl
  flags:
    preis: 1


i_teig:
  type: item
  material: cooked_porkchop
  display name: Teig
  flags:
    preis: 2
  recipes:
      1:
          type: furnace
          cook_time: 1s
          input: i_mehl


i_brot:
  type: item
  material: bread
  display name: Brot
  flags:
    preis: 3
  recipes:
      1:
          type: furnace
          cook_time: 1s
          input: i_teig


i_weintrauben:
  type: item
  flags:
    preis: 3
  material: sweet_berries
  display name: Weintrauben


i_wein:
  type: item
  material: cooked_mutton
  display name: Wein
  flags:
    preis: 4

i_weinfass:
  type: item
  material: barrel
  display name: Weinfass
  flags:
    preis: 12


i_stiefel:
  type: item
  material: leather_boots
  display name: Stiefel
  flags:
    preis: 10


i_topf:
  type: item
  material: bucket
  display name: Topf
  flags:
    preis: 8


i_wachtelei:
  type: item
  material: turtle_egg
  display name: Wachtelei
  flags:
    preis: 4


i_apfel:
  type: item
  material: apple
  display name: Apfel
  flags:
    preis: 2


i_schwanenfeder:
  type: item
  material: feather
  display name: Schwanenfeder
  flags:
    preis: 3


i_taschenuhr:
  type: item
  material: clock
  display name: Taschenuhr
  flags:
    preis: 30


i_teller:
  type: item
  material: bowl
  display name: Teller
  flags:
    preis: 3


i_wurfnetz:
  type: item
  material: cobweb
  display name: Wurfnetz
  flags:
    preis: 3
    text: Zum Einfangen von ungefährlichen Tieren.


i_wurfnetz_verbessert:
  type: item
  material: cobweb
  display name: Verbessertes Wurfnetz
  flags:
    preis: 30
    text: Zum Einfangen von Gegnern oder Tieren.


i_wolfspelz:
  type: item
  material: leather
  display name: Wolfspelz
  flags:
    preis: 5


i_wolffleisch:
  type: item
  material: mutton
  display name: Wolffleisch
  flags:
    preis: 3


i_knochen:
  type: item
  material: bone
  display name: Knochen
  flags:
    preis: 3


i_zahn:
  type: item
  material: iron_nugget
  display name: Zahn
  flags:
    preis: 2


i_dreizack:
  type: item
  material: trident
  display name: Dreizack
  flags:
    preis: 30


i_totenkopf:
  type: item
  material: wither_skeleton_head
  display name: Schwarzer Totenschädel
  flags:
    preis: 50


i_roterkackstock:
  type: item
  material: wooden_sword
  display name: Dummer roter Stock
  mechanisms:
    custom_model_data: 1
  flags:
    preis: 99
