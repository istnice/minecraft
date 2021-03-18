

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