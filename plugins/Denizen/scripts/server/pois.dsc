poi_command:
  name: poi
  type: command
  description: POI
  usage: /poi [neu/tp/teleport/loeschen/liste] [POINAME]
  tab complete:
  - define arg1s <list[new|tp|teleport|remove|help|list|save|load]>
  - if !<[arg1s].contains[<context.args.get[1]>]>:
    - determine <[arg1s]>
  - else if <list[neu|new|create].contains[<context.args.get[1]>]>:
    - determine POINAME
  - else if <list[teleport|loeschen|löschen|tp].contains[<context.args.get[1]>]>:
    - determine <server.flag[pois].keys>
  script:
  - inject permission_op

  # | HELP
  - if !<list[neu|new|add|create|tp|teleport|loeschen|löschen|liste|list|remove|rem|del].contains[<context.args.get[1]||null>]>:
    - narrate <gray>----------------------------
    - narrate "<white>P<gray>oints <white>o<gray>f <white>I<gray>nterests sind mit Namen markierte Orte, die auf der Karte angezeigt und zum Teleportieren verwendet werden."
    - narrate "<yellow>/poi list"
    - narrate "  <gray>- Listet Namen aller POIs"
    - narrate "<yellow>/poi create <light_purple>[ID]"
    - narrate "  <gray>- Erstellt/ändert einen Marker"
    - narrate "<yellow>/poi teleport <light_purple>[ID]"
    - narrate "  <gray>- Teleportiert zu einem Marker"
    - narrate "<yellow>/poi remove <light_purple>[ID]"
    - narrate "  <gray>- Löscht einen Marker"
    - narrate <gray>-----------------------------
    - stop

  # | LIST
  - if <list[liste|list].contains[<context.args.get[1]||null>]>:
    # load list of poi
    - yaml unload id:pois
    - define pois <yaml[pois].read[]>
    - yaml unload id:pois
    - define msg ""
    - foreach <[pois].keys> as:k:
      - define msg "<[msg]> <[k]>"
    - narrate <[msg]>
    - stop

  # | CREEATE
  - if <list[neu|new|create|add].contains[<context.args.get[1]||null>]>:
    - if <context.args.get[2]||null> == null:
      - narrate "<red>Name fehlt: <yellow>/poi neu <red>[NAME]"
      - stop
    - define name <context.args.get[2]>
    - define poi <map[name/<[name]>|location/<player.location>|x/<player.location.x>|y/<player.location.y>|z/<player.location.z>|id/poi]>
    - flag server pois.<[name]>:<[poi]>
    - run pois_save_task
    - stop

  # | TELEPORT
  - if <list[teleport|tp].contains[<context.args.get[1]||null>]>:
    - if <[name]> == null:
      - narrate "<red>Name fehlt: <yellow>/poi tp <red>[NAME]"
      - stop
    - define target <server.flag[pois.<context.args.get[2]||null>.location]||null>
    - if <[target]> == null:
      - narrate "<red>POI nicht gefunden.<gray> Liste aller POIs: <yellow>/poi liste"
      - stop
    - teleport <player> <[target]>


tpoi_command:
  type: command
  debug: false
  name: tpoi
  description: teleportiert spieler zu eingetragenem POI (kurzform von /poi tp)
  usage: /tpoi [POINAME]
  tab complete:
    - determine <server.flag[pois].keys>
  script:
  - inject permission_op
  - narrate "<gray>Teleportiert durch Alias. <gray>Alle POI-Funktionen mit <yellow>/poi"
  - define cmd "poi tp <context.args.get[1]>"
  - execute as_player <[cmd]>


pois_save_task:
    type: task
    script:
    - yaml create id:pois
    - ~yaml load:data/pois.yml id:pois
    - yaml id:pois set pois:<server.flag[pois]>
    - if <yaml[pois].has_changes>:
      - yaml savefile:data/pois.yml id:pois
      - narrate "<green>POIs gespeichert"
    - else:
      - narrate "<gray>Keine Änderung in POIs."
    - yaml unload id:pois


pois_load_task:
    type: task
    script:
    - yaml create id:pois
    - ~yaml load:data/pois.yml id:pois
    - flag server pois:<yaml[pois].read[pois]||null>
    - yaml unload id:pois


pois_world:
    type: world
    debug: true
    events:
        on reload scripts:
        - run pois_load_task