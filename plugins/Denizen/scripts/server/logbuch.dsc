open_book_event:
    type: world
    events:
        on player right clicks block with:written_book:
        - if <context.item.display> == Logbuch:
        # on player right clicks with logbuch_item:
            - inject logbuch_render
            - determine CANCELLED
        on player joins:
        - if !<player.inventory.contains.scriptname[logbuch_item]>:
            - give <item[logbuch_item].with[display=Logbuch]> slot:9
        on player clicks item in inventory:
        - if <context.item.display> == Logbuch:
            - determine cancelled
        on player drops item:
        - if <context.item.display> == Logbuch:
            - determine cancelled

logbuch_cmd:
    type: command
    name: logbuch
    description: Öffnet des Spielers Logbuch
    script:
    # - inject permission_op
    - inject logbuch_render

logbuch_render:
    type: task
    script:
    - define buch <item[logbuch_item]>
    # Startseite
    # - define startseite "Logbuch von <player.name><p>Geld: <gold><player.flag[geld]||0><black><p>Ruf:<n>"
    - define startseite "Logbuch von <player.name><p>Geld: <proc[money_to_string].context[<player.flag[geld]||0>|light]><black><p>Ruf:<n>"
    - define startseite "<[startseite]> Soldaten: <blue><player.flag[ruf.soldaten]||0><n><black>"
    - define startseite "<[startseite]> Magier: <blue><player.flag[ruf.magier]||0><n><black>"
    - define startseite "<[startseite]> Handwerker: <blue><player.flag[ruf.handwerker]||0><black><p>"
    - if <player.has_flag[spawnpoint]>:
        - define startseite "<[startseite]>Bett: <dark_green><player.flag[spwanpoint]||Keiner><black><p>"
    - else:
        - define startseite "<[startseite]>Bett: <dark_red>Nicht Gesetzt!<black><p>"
    - if <player.is_op>:
        - define menu_btn "<element[<dark_blue>☞ Admin-Menu].on_click[/menu]>"
        - define startseite <[startseite]><n><[menu_btn]>
    # Questseite
    - define questseite "Aktive Quests:<p>"
    - foreach <player.flag[quests.aktiv]> as:quest:
        - define stages <server.flag[quests.<[quest].get[id]>].get[stages]>
        # - define updatestagecmd "/quests upstage <[quest].get[id]>"
        - define showqlogcmd "/quests logbuch <[quest].get[id]>"
        - define questseite "<[questseite]><n><gold>☞ <[quest].get[name].on_click[<[showqlogcmd]>]> <black><player.flag[quests.aktiv.<[quest].get[id]>.stage].sub_int[1]>/<[stages].size>"
    - define historyseite "<black>Erledigte Quests (<player.flag[quests.fertig].keys.size||0>):<p><gray>"
    - foreach <player.flag[quests.fertig]> as:quest:
        - define historyseite "<[historyseite]><n>⚜ <[quest].get[name]>"
    - adjust def:buch book_pages:<list[<[startseite]>|<[questseite]>|<[historyseite]>]>
    - adjust <player> show_book:<[buch]>


logbuch_item:
  type: book
  title: Logbuch-Title
  author: Spieler
  signed: true
  # To create a newline, use the tag <n>. To create a paragraph, use <p>.
  text:
  - "Noch kein Eintrag"
