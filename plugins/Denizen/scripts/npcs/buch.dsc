buch_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:proximity state:true radius:10
        - sneak <npc> start fake
        - if !<npc.has_flag[dialogid]>:
          - flag <npc> dialogid:<npc.name>
        - yaml create id:dialog_<npc.flag[dialogid]>
        - ~yaml savefile:dialogs/test.yml id:dialog_<npc.flag[dialogid]>
        # - flag <npc> buch.default "default"
        on spawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> start fake
        on despawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> stopfake
        on enter proximity:
        - flag <npc> dampf:true duration:30
        - while <player.is_online> && <npc.has_flag[dampf]>:
          - playeffect effect:CLOUD at:<npc.location.add[0,2.5,0]> quantity:1 offset:0
          - wait 2
        on leave proximity:
        - flag <npc> dampf:!
        # on move proximity:
        # - playeffect effect:CLOUD at:<npc.location.add[0,2.5,0]> quantity:1 offset:0
        # - walk <npc> <player.location>
        on click:
        # - playeffect effect:VILLAGER_HAPPY location:<npc.location>
        # check requirements
        - if <npc.has_flag[req]>:
            # - narrate "<gray> Req found"
            - define nruf <npc.flag[req.ruf]||null>
            - define pruf <player.flag[ruf.<npc.flag[req.gilde]>]||0>
            - if <[nruf]> > <[pruf]> || <[nruf]>==null:
                - narrate "<red>Nicht genug Ruf um mit diesem NPC zu reden! <[pruf]>/<[nruf]>"
                - determine cancelled
        - flag <player> buchdialog:<npc>
        - execute as_player "npcbuch seite start"
        # read file
        - determine cancelled


buch_cmd:
    type: command
    name: npcbuch
    usage: /npcbuch [neu/ruf/seite/editor]
    description: assigns trader and sets items
    debug: false
    script:
    # check commands
    - if !<list[neu|info|ruf|seite|editor|speichern].contains[<context.args.get[1]||null>]>:
        - narrate <gray>-----------------------------
        - narrate "<yellow>/npcbuch neu <white>[NAME]"
        - narrate "  <gray>- Erstellt NPC mit Buchdialog (Name ohne Leerzeichen)"
        - narrate "<yellow>/npcbuch editor"
        - narrate "  <gray>- Öffnet ein chat editor zum anpassen des Dialogs"
        - narrate "<yellow>/npcbuch ruf <white>[GILDE] [MENGE]"
        - narrate "  <gray>- Erforderlichen Ruf zum Ansprechen des NPCs anpassen"
        - narrate "<yellow>/npcbuch seite <white>[ANSICHT-ID]"
        - narrate "  <gray>- Springt direkt zu einer Stelle des Dialogs"
        - narrate "<yellow>/npcbuch speichern"
        - narrate "  <gray>- Speichert den Dialog auf dem Server (restart proof)"
        - narrate <gray>-----------------------------
        - stop
    # ANSICHT
    - if <context.args.get[1]> == seite:
      - define ansicht <context.args.get[2]>
      - define npc <player.flag[buchdialog]>
      - define id <[npc].flag[dialogid]>
      - yaml create id:<[id]>
      - yaml load:dialogs/<[id]>.yml id:<[id]>
      - define view <yaml[<[id]>].read[<[ansicht]>]>
      - define seite <[view].get[text]>
      - define ants <[view].get[antworten]>
      # antworten anhängen
      - if <[ants].values.size> > 0:
        - foreach <[ants].values> as:ant:
          - define weiter "/npcbuch seite <[ant].get[weiter]>"
          # - define color <color[<[ant].get[color]||blue>]>
          - define antw <[ant].get[text].parse_color[&].on_click[<[weiter]>]>
          - define seite <[seite]><p><[antw]>
      - define book <item[buch_item]>
      # TODO: multiple pages
      - adjust def:book book_pages:<list[<[seite]>|]>
      - yaml unload id:<[id]>
      - adjust <player> show_book:<[book]>
    # SPEICHERN
    - if <context.args.get[1]> == save:
      # - yaml create id:dialog_test
      # - yaml id:dialog_test set dialog.default:HelloWorld
      - ~yaml savefile:dialogs/test.yml id:dialog_test
      - narrate "SAVED to test.yml (in arbeit)"


buch_item:
  type: book
  title: Der Titel
  author: Die Autorin
  signed: true
  # To create a newline, use the tag <n>. To create a paragraph, use <p>.
  text:
  - "text von <n>seite 1"