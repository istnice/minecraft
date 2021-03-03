poi_yaml_load:
    type: world
    events:
        on server start:
        - yaml create id:pois
        # - yaml load:pois.yml id:pois
        on shutdown:
        - yaml unload id:pois
        # check has changes? save?

teleport_poi_command:
  type: command
  name: tpoi
  description: teleportiert spieler zu eingetragenem POI (kurzform von /poi tp)
  usage: /tpoi [POINAME]
  permission: denizen.teleport
  tab complete:
    - determine <server.flag[poinames]>
  script:
  - narrate "<gray>/tpoi ist eine Abkürzung für <yellow>/poi tpl<gray>. Mit <yellow>/poi<gray> hast du alle Möglichkeiten."
  - define name <context.args.get[1]||null>
  - ~yaml load:pois.yml id:pois
  - if <[name]> == null:
    - narrate "<red>Name fehlt: <yellow>/poi tp <red>[NAME]"
    - narrate "Verfügbare POI/Namen:"
    - define pois <yaml[pois].read[]>
    - define msg ""
    - foreach <[pois].keys> as:k:
      - define msg "<[msg]> <[k]>"
    - narrate <[msg]>
    - stop
  - define poi <yaml[pois].read[<[name]>]||null>
  - if <[poi]> == null:
    - narrate "<red>POI nicht gefunden.<gray> Liste aller POIs: <yellow>/poi liste"
    - stop
  - teleport <player> <[poi].get[location]>
  - yaml unload id:pois


set_poi_command:
  name: poi
  type: command
  description: POI
  usage: /poi [neu/tp/teleport/loeschen/liste] [POINAME]
  permission: denizen.mod
  tab complete:
  - define arg1s <list[neu|tp|teleport|loeschen|löschen|hilfe|liste]>
  - if !<[arg1s].contains[<context.args.get[1]>]>:
    - determine <[arg1s]>
  - else if <list[neu|new|create].contains[<context.args.get[1]>]>:
    - determine POINAME
  - else if <list[teleport|loeschen|löschen|tp].contains[<context.args.get[1]>]>:
    - determine <server.flag[poinames]>
  script:
  - if !<player.has_permission[denizen.mod]||<player.is_op||context.server>>:
    - narrate "<red>Nope! Das darfst du nicht!"
    - stop
  # |HILFE
  - if !<list[neu|tp|teleport|loeschen|löschen|liste|list].contains[<context.args.get[1]||null>]>:
    - narrate "<yellow>------------ <white>Befehl: /poi<yellow> --------"
    - narrate "<white>P<gray>oints <white>o<gray>f <white>I<gray>nterests sind mit Namen markierte Orte."
    # - narrate "<yellow>/poi hilfe"
    # - narrate "  <gray>- Zeigt diese Hilfe an"
    - narrate "<yellow>/poi liste"
    - narrate "  <gray>- Listet Namen aller POIs"
    - narrate "<yellow>/poi neu <light_purple>[NAME]"
    - narrate "  <gray>- Erstellt/ändert einen Marker (ohne Leerzeichen)"
    - narrate "<yellow>/poi tp <light_purple>[NAME]"
    - narrate "  <gray>- Teleportiert zu einem Marker"
    - narrate "<yellow>/poi löschen <light_purple>[NAME]"
    - narrate "  <gray>- Löscht einen Marker"
    # - narrate <yellow>-----------------------------
    - stop
  # |LISTE
  - else if <list[liste|list].contains[<context.args.get[1]||null>]>:
    # load list of poi
    - yaml unload id:pois
    - define pois <yaml[pois].read[]>
    - yaml unload id:pois
    - define msg ""
    - foreach <[pois].keys> as:k:
      - define msg "<[msg]> <[k]>"
    - narrate <[msg]>
    - stop
  # |NEU
  - else if <list[neu].contains[<context.args.get[1]||null>]>:
    - if <context.args.get[2]||null> == null:
      - narrate "<red>Name fehlt: <yellow>/poi neu <red>[NAME]"
      - stop
    - define name <context.args.get[2]>
    - define poi <map[name/<[name]>|location/<player.location>|x/<player.location.x>|y/<player.location.y>|z/<player.location.z>|id/poi]>
    - yaml create id:pois
    - ~yaml load:pois.yml id:pois
    - yaml id:pois set <[name]>:<[poi]>
    - define pois <yaml[pois].read[]>
    - if <yaml[pois].has_changes>:
      - yaml savefile:pois.yml id:pois
      - narrate "<green>POI gespeichert: <[name]>"
    - else:
      - narrate "<gray>Keine Änderung."
    - yaml unload id:pois
    - stop
  # |TELEPORT
  - else if <list[teleport|tp].contains[<context.args.get[1]||null>]>:
    - define name <context.args.get[2]||null>
    - if <[name]> == null:
      - narrate "<red>Name fehlt: <yellow>/poi tp <red>[NAME]"
      - stop
    # - yaml create id:pois
    - ~yaml load:pois.yml id:pois
    - define poi <yaml[pois].read[<[name]>]||null>
    - if <[poi]> == null:
      - narrate "<red>POI nicht gefunden.<gray> Liste aller POIs: <yellow>/poi liste"
      - stop
    - teleport <player> <[poi].get[location]>
    - yaml unload id:pois