# +-------------------
# |
# | Sammlung von Server commands
# |
# +----------------------
# /wetter
# /ruf
# /geld
# /fakesneak
# /skin
# /todo
# ---------------------------- END HEADER ----------------------------

permission_op:
  type: task
  script:
  - if !<player.is_op||context.server>:
    - narrate "<red>Keine Berechtigung!"
    - stop


skyblock_cmd:
  type: command
  name: skyblock
  usage: /skyblock
  script:
  - inject permission_op
  # - adjust <player.location.sub[0,1,0]> block_type:<material[light_blue_wool]>
  - execute as_player "setblock ~ -1 ~ light_blue_wool"


flyspeed_cmd:
  type: command
  name: flyspeed
  usage: /flyspeed
  tab complete:
  - define hint "(0-1)"
  - determine <list[hint]>
  script:
  - inject permission_op
  - if <context.args.get[1]||null> == null:
    - adjust <player> fly_speed:0.05
    - narrate "<gray>Flyspeed zurückgesetzt auf 0.05. Mit <yellow>/flyspeed <light_purple>ZAHL <gray>ändern (0 bis 1)"
    - stop
  - adjust <player> fly_speed:<context.args.get[1]>
  - narrate "<gray>Flyspeed auf <context.args.get[1]> gesetzt. Mit <yellow>/flyspeed <gray>stellst du es auf Standard zurück."


wetter_cmd:
    type: command
    debug: false
    name: wetter
    usage: /wetter
    description: Toggelt das Wetter/Zeit
    tab complete:
    - define args1 <list[ja|nein|info|hilfe]>
    - if !<[args1].contains[<context.args.get[1]||null>]>:
        - determine <[args1]>
    script:
    - inject permission_op
    - if !<list[ja|nein|info].contains[<context.args.get[1]||null>]>:
        - narrate <gray>-----------------------------
        - narrate "<yellow>/wetter info"
        - narrate "  <gray>- Zeigt aktuelles Wetter sowie aktuelle gamerules"
        - narrate "<yellow>/wetter ja"
        - narrate "  <gray>- Aktiviert den Wetter und Tag/Nacht Zyklus"
        - narrate "<yellow>/wetter nein"
        - narrate "  <gray>- Stellt das Wetter für immer auf sonnigen Nachmittag"
        - narrate <gray>-----------------------------
        - stop
    - if <context.args.get[1]> == ja:
      - gamerule <world> doWeatherCycle true
      - gamerule <world> doDaylightCycle true
      - narrate "<gray>Die Tageszeit läuft weiter und das Wetter ändert sich..."
      - stop
    - else if <context.args.get[1]> == nein:
      - gamerule <world> doWeatherCycle false
      - gamerule <world> doDaylightCycle false
      - weather sunny
      - time set noon
      - narrate "<gray>Es bleibt ein sonniger Nachmittag."
      - stop
    - else if <context.args.get[1]> == info:
      - narrate "<blue>TODO:<gray> Wetter-Info noch nicht implementiert."


ruf_command:
    type: command
    debug: false
    name: ruf
    usage: /ruf
    description: gibt spieler ruf bei gilde
    tab complete:
    - define args1 <list[geben|nehmen|info|hilfe]>
    - define gilden <list[soldaten|magier|zwergen|fischer|handwerker]>
    - if !<[args1].contains[<context.args.get[1]||null>]>:
        - determine <[args1]>
    - if <list[geben|nehmen].contains[<context.args.get[1]>]>:
      - if !<[gilden].contains[<context.args.get[2]||null>]>:
        - determine <[gilden]>
      - else if <context.args.get[3]||null> != null:
        - define pnames <list[]>
        - foreach <server.online_players> as:p:
          - define pnames <[pnames].include[<[p].name>]>
        - determine <[pnames]>
      - else:
        - determine <list[ZAHL]>
    - if <context.args.get[1]> == info:
        - define pnames <list[]>
        - foreach <server.online_players> as:p:
          - define pnames <[pnames].include[<[p].name>]>
        - determine <[pnames]>
    script:
    - inject permission_op
    - if !<list[geben|nehmen|info].contains[<context.args.get[1]||null>]>:
        - narrate <gray>-----------------------------
        - narrate "<yellow>/ruf info <light_purple>(SPIELER)"
        - narrate "  <gray>- Zeigt eigenen Ruf. Optional: Von angegebenem Spieler"
        - narrate "<yellow>/ruf geben <light_purple>GILDE MENGE (SPIELER)"
        - narrate "  <gray>- Gibt sich selbst Ruf bei Gilde. Optional: an angegebenen Spieler"
        - narrate "<yellow>/ruf nehmen <light_purple>GILDE MENGE (SPIELER)"
        - narrate "  <gray>- Genau wie geben nur Wert wird abgezogen (nicht unter 0)"
        - narrate <gray>-----------------------------
        - stop
    - if <context.args.get[1]> == info:
      - define p <server.match_player[<context.args.get[2]||<player.name>>]>
      - if <[p].has_flag[ruf]>:
        - narrate "<gray>--- <white><[p].name>s Ruf <gray>---"
        - foreach <[p].flag[ruf].keys> as:k:
          - narrate "<gray><[k]> <aqua><[p].flag[ruf.<[k]>]>"
      - else:
        - narrate "<[p].name> - Noch kein Ruf eingetragen."
    - if <list[geben|nehmen].contains[<context.args.get[1]>]>:
      - define p <server.match_player[<context.args.get[4]||<player.name>>]>
      - define gilde <context.args.get[2]||fehler>
      - define menge <context.args.get[3]||0>
      - define wert <[p].flag[ruf.<[gilde]>]||0>
      - if <context.args.get[1]> == geben:
        - define neu <[wert].add_int[<[menge]>]>
        - narrate "<gray><[p].name> <aqua><[menge]><gray> Ruf bei den <[gilde]> gegeben."
      - else:
        - define neu <[wert].sub_int[<[menge]>]>
        - narrate "<gray><[p].name> <aqua><[menge]><gray> Ruf bei den <[gilde]> genommen."
      - if <[neu]> < 0:
        - define neu 0
      - flag <[p]> ruf.<[gilde]>:<[neu]>



geld:
  type: command
  name: geld
  usage: /geld
  description: Gibt/nimmt dir oder einem Spieler geld
  tab complete:
  - define args1 <list[geben|nehmen|info|hilfe]>
  - if !<[args1].contains[<context.args.get[1]||null>]>:
      - determine <[args1]>
  - if <list[geben|nehmen].contains[<context.args.get[1]>]>:
    - if <context.args.get[2]||null> != null:
      - define pnames <list[]>
      - foreach <server.online_players> as:p:
        - define pnames <[pnames].include[<[p].name>]>
      - determine <[pnames]>
    - else:
      - determine <list[MENGE]>
  - if <context.args.get[1]> == info:
      - define pnames <list[]>
      - foreach <server.online_players> as:p:
        - define pnames <[pnames].include[<[p].name>]>
      - determine <[pnames]>
  script:
  - inject permission_op
  - if !<list[geben|nehmen|info].contains[<context.args.get[1]||null>]>:
      - narrate <gray>-----------------------------
      - narrate "<yellow>/geld info <light_purple>(SPIELER)"
      - narrate "  <gray>- Zeigt eigenes Geld. Optional: Von angegebenem Spieler"
      - narrate "<yellow>/geld geben <light_purple>MENGE (SPIELER)"
      - narrate "  <gray>- Gibt sich selbst Geld. Optional: an angegebenen Spieler"
      - narrate "<yellow>/geld nehmen <light_purple>MENGE (SPIELER)"
      - narrate "  <gray>- Genau wie geben nur Wert wird abgezogen (nicht unter 0)"
      - narrate <gray>-----------------------------
      - stop
  - if !<player.has_flag[geld]>:
    - flag <player> geld:0
  - if <context.args.get[1]||null> == info:
    - define p <server.match_player[<context.args.get[2]||<player.name>>]>
    - if not <[p].has_flag[geld]>:
      - flag <[p]> geld:0
    - narrate "<gray><[p].name> hat <gold><[p].flag[geld]><gray> Geld."
    - stop
  - else if <list[geben|nehmen].contains[<context.args.get[1]||null>]>:
    - define p <server.match_player[<context.args.get[3]||<player.name>>]>
    - define g <context.args.get[2]||0>
    - if <context.args.get[2]> == geben:
      - flag <[p]> geld:<[p].flag[geld].add_int[<[g]>]>
      - narrate "<gray><[p].name> hat <gold><[g]><gray> Geld bekommen."
    - else:
      - flag <[p]> geld:<[p].flag[geld].sub_int[<[g]>]>
      - narrate "<gray><[p].name> hat <gold><[g]><gray> Geld verloren."


zeit_cmd:
  type: command
  debug: false
  name: zeit
  usage: /zeit
  script:
  - inject permission_op
  - define ticks <world[world].time>
  - narrate "Es ist <[ticks].div[1000].add[6].round_down> Uhr (<[ticks]> t)"


noteregion_cmd:
  type: command
  debug: false
  name: noteregion
  usage: /noteregion
  script:
  - inject permission_op
  - if <context.args.get[1]||null> == null:
    - narrate "<red>Name fehlt <gray>um Region zu notieren: <yellow>/noteregion <light_purple>NAME"
    - stop
  - define region <player.we_selection>
  - note <[region]> as:<context.args.get[1]>
  - narrate "<gray>Region notiert!"


skin_cmd:
    type: command
    debug: false
    name: skin
    usage: /skin [speichern/laden]
    description: speichert, lädt, listet skins auf dem server
    permission: denizen.skin
    tab complete:
    - define args1 <list[speichern|laden|info|hilfe]>
    - if !<[args1].contains[<context.args.get[1]||null>]>:
      - determine <[args1]>
    - if <context.args.get[1]||null> == laden:
      - determine <server.flag[npc_skins].keys>
    script:
    - inject permission_op
    - if !<list[speichern|laden|info].contains[<context.args.get[1]||null>]>:
        - narrate <gray>-----------------------------
        - narrate "<yellow>/skin speichern <white>[SKINNAME]"
        - narrate "  <gray>- Speichert den Skin eines NPC auf dem Server (ohne leerzeichen)"
        - narrate "<yellow>/skin laden <white>[SKINNAME]"
        - narrate "  <gray>- Gibt einem NPC einen gespeicherten Skin"
        - narrate "<yellow>/skin info"
        - narrate "  <gray>- Listet alle gespeicherten Skins auf"
        - narrate <gray>-----------------------------
        - stop
    # list
    - if <context.args.get[1]> == info:
      - define skinmap <server.flag[npc_skins]>
      - foreach <[skinmap].keys> as:skin_name:
        - narrate <[skin_name]>
    # validate npc/name
    - if <player.selected_npc||null> == null:
      - narrate "<red>Kein NPC ausgewählt!"
      - stop
    - if <context.args.get[2]||null> == null:
      - narrate "<red>Name Fehlt:<yellow> /skin <context.args.get[1]> <red>[NAME]"
      - stop
    # save
    - if <context.args.get[1]> == speichern:
      - flag server npc_skins.<context.args.get[2].escaped>:<player.selected_npc.skin_blob>;<player.selected_npc.name>
      - narrate "<green>Skin gespeichert:<white> <context.args.get[2].escaped>"
      - stop
    # load
    - if <context.args.get[1]> == laden:
      - if !<server.has_flag[npc_skins.<context.args.get[2].escaped>]>:
        - narrate "<red>Kein Skin mit diesem namen gefunden: <white><context.args.get[2].escaped>"
        - stop
      - adjust <player.selected_npc> skin_blob:<server.flag[npc_skins.<context.args.get[2].escaped>]>
      - narrate "<green>Skin geladen: <white><context.args.get[2].escaped>"


bookui_cmd:
  type: command
  name: bookui
  usage: /bookui
  description: open book
  script:
  - inject permission_op
  - define book <item[ui_book]>
  # - adjust <[book]> book_pages:"Neue Seite"
  - adjust <player> show_book:<[book]>

ui_book:
  type: book
  title: Der Titel
  author: Die Autorin
  signed: true
  text:
  - "text von <n>seite 1"
  - "text von <n>seite 2"

todo_block:
  type: command
  name: todo
  usage: /todo
  script:
  - inject permission_op
  # - execute as:<player> ""
  # - modifyblock <player.location.add[0,-1,0]> red_wool
  - worldedit paste file:todo position:<player.location>
  # - worldedit paste

gamemode_cmd:
  type: command
  name: gm
  usage: /gm
  script:
    - inject permission_op
    - if <player.gamemode> == creative:
      - adjust <player> gamemode:adventure
    - else if <player.gamemode> == adventure:
      - adjust <player> gamemode:creative
    - else:
      - narrate "<gray>Du bist im <player.gamemode> mode, der Befehl dient zum schnellen Wechsel zwischen Adventure/Creative"


update_cmd:
  type: command
  name: update
  usage: /update
  description: update regions, npcs, dialogs and other data
  script:
  - inject permission_op
  # - narrate <world[world]>
  # - foreach <world[world].list_regions> as:region:
  #   # only works for cuboids :/
  #   - note <[region]> as:<[region].id>
  #   - narrate "<green>notiert: <[region].id>"
  - sidebar set "title:Sidebar.. " "values:Eine Reihe|mit eigenen|Daten..|ping<&co> <player.ping>" "scores:|||"


fussweg:
  type: command
  name: fussweg
  usage: /fussweg [RADIUS] [MATERIAL]
  description: macht fussweg
  script:
  - inject permission_op
  - narrate "Mach Fussweg!"
  - define r <context.args.get[1]||30>
  - define m <context.args.get[2]||light_blue_wool>
  - define p "1<&pc>cobblestone,1<&pc>gravel,1<&pc>andesite,1<&pc>polished_andesite,1.5<&pc>grass_path,1<&pc>cracked_stone_bricks,1<&pc>stone_bricks"
  - execute as_player "/replacenear <[r]> <[m]> <[p]>"