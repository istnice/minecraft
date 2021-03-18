trader_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - sneak <npc> start fake
        on click:
        # check requirements
        - if <npc.has_flag[req]>:
            # - narrate "<gray> Req found"
            - define nruf <npc.flag[req.ruf]||null>
            - define pruf <player.flag[ruf.<npc.flag[req.gilde]>]||0>
            - if <[nruf]> > <[pruf]> || <[nruf]>==null:
                - narrate "<red>Nicht genug Ruf um mit diesem Händler zu reden! <[pruf]>/<[nruf]>"
                - determine cancelled

        # temp offer add:
        # - flag <npc> offers.offer1:<item[close_item]>
        - flag <player> active_trader_name:<npc.name>
        - flag <player> active_trader:<npc>
        - inventory open d:<inventory[trader_inventory]>
        # TODO: change lore for added items not on inventory open
        # - inventory adjust
        # - inventory adjust
        - determine cancelled


trader_inventory:
    type: inventory
    debug: false
    inventory: CHEST
    title: Handel mit <player.flag[active_trader_name]>
    size: 27
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] [close]
    definitions:
        close: <item[close_item]>
    procedural items:
        - define list <list>
        - define npc <player.flag[active_trader]>
        - foreach <npc.flag[offers]> as:offer:
            - if <[offer].get[empty]||false>:
                - define item <item[empty_item]>
            - else:
                - define lore "Preis: <[offer].get[preis]>bg"
                - define item <[offer].get[item].unescaped>
                # - narrate "Item: <[item]>"
                # - narrate "Anzahl: <[item].quantity>"
                - adjust def:item lore:<[lore]>
                - define item <[item].with[lore=<[lore]>]>
            - define list:->:<[item]>
        - determine <[list]>

trader_cmd:
    type: command
    name: npctrader
    usage: /npctrader [create/add/clear/set/buy/ruf]
    description: assigns trader and sets items
    debug: false
    script:
    # check commands
    - if !<list[create|add|clear|set|buy|rem|info|restock|ruf].contains[<context.args.get[1]||null>]>:
        - narrate <gray>-----------------------------
        - narrate "<yellow>/npctrader create <white>[NAME]"
        - narrate "  <gray>- Erstellt einen neuen Trader"
        - narrate "<yellow>/npctrader set"
        - narrate "  <gray>- Macht einen NPC zum trader"
        - narrate "<yellow>/npctrader add [preis]"
        - narrate "  <gray>- Fügt das Item aus der Hand den Angeboten hinzu"
        - narrate "<yellow>/npctrader buy [preis]"
        - narrate "  <gray>- Aktuelles item wird vom Händler gekauft."
        - narrate "<yellow>/npctrader restock"
        - narrate "  <gray>- Füllt Vorrat des Händlers auf"
        - narrate "<yellow>/npctrader ruf <white>[GILDE] [RUF]"
        - narrate "  <gray>- Erforderlicher Ruf um zu handeln. (zB magier 200). Negativer wert um zu deaktivieren"
        - narrate "<yellow>/npctrader clear - Löscht ALLE Angebote und Einkäufe"
        - narrate <gray>-----------------------------
        - stop

    - if <context.args.get[1]> == create:
        - define name <context.args.get[2]||null>
        - if <[name]> == null:
            - narrate "<red> Name fehlt: <yellow>/npctrader create <red>[Name]"
            - stop
        # - narrate "<gray>Neuen NPC als Trader erstellen"
        - create player <[name]> <player.location> traits:lookclose save:npc
        - define npc <entry[npc].created_npc>
        - adjust <player> selected_npc:<[npc]>
        - define skin_blob <server.flag[npc_skins.trader]||null>
        - if skin_blob == null:
            - narrate "<red>Kein Skin namens trader gefunden:"
        - else:
            - adjust <[npc]> skin_blob:<server.flag[npc_skins.trader]>
        - assignment set script:trader_assi npc:<[npc]>
        - narrate "<gray>Trader erstellt, ergänze Angebote (item in mainhand) mit <yellow>/npctrader add <white>[PREIS]"
        - stop

    - if <player.selected_npc||null> == null:
        - narrate "<red>Bitte NPC auswählen (<yellow>/npc sel<red>)!"
        - stop
    - define npc <player.selected_npc>
    - assignment set script:trader_assi npc:<player.selected_npc>
    # handle arguments
    - if <context.args.get[1]> == set:
        - narrate "<&a>NPC ist jetzt ein Händler."

    # show info
    - if <context.args.get[1]> == info:
        - if <[npc].has_flag[offers]>:
            - narrate "Angebote: <gray>slot. item (preis)"
            - define i 1
            - foreach <player.selected_npc.flag[offers]> as:offer:
                - narrate "<[i]>. <[offer].get[item].material.name> (<[offer].get[preis]>)"
                - define i <[i].add_int[1]>
        - if <[npc].has_flag[buys]>:
            - narrate "Ankauf: <gray>slot. item (preis)"
            - define i 1
            - foreach <player.selected_npc.flag[buys]> as:buy:
                - narrate "<[i]>. <[buy].get[item].material.name> (<[buy].get[preis]>)"
                - define i <[i].add_int[1]>

    # add offers
    - else if <context.args.get[1]> == add:
        - define preis <context.args.get[2]>
        - define item <player.item_in_hand>
        # - define item <player.item_in_hand.material>
        - define offer <map[item/<[item].escaped>|preis/<[preis]>|stock/<[item].quantity>]>
        - narrate "angebot erstellt: <[offer]>"
        - flag <player.selected_npc> offers:->:<[offer]>
        # - inventory adjust slot:<player.held_item_slot> lore:!
        - narrate "<&a>Angebot aufgenommen."

    # add buys
    - else if <context.args.get[1]> == buy:
        - define preis <context.args.get[2]>
        - define item <item[<player.item_in_hand>]>
        - define buy <map[item/<[item]>|preis/<[preis]>]>
        - narrate "ankauf erstellt: <[buy]>"
        - flag <player.selected_npc> buys:->:<[buy]>

    # clear offers
    - else if <context.args.get[1]> == clear:
        - flag <player.selected_npc> offers:!
        - flag <player.selected_npc> buys:!
        - narrate "<&a>Angebote entfernt."

    # remove single offer/buy
    - else if <context.args.get[1]> == rem:
        - define lname <context.args.get[2]>
        - define idx <context.args.get[3]>
        - flag <player.selected_npc> <[lname]>:<player.selected_npc.flag[<[lname]>].remove[<[idx]>]>

    # RUF
    - else if <context.args.get[1]> == ruf:
        - define gilde <context.args.get[2]||null>
        - define ruf <context.args.get[3]||null>
        - if <[ruf]> < 0:
            - flag <[npc]> req:!
            - narrate "<gray> NPC handelt mit jedem."
        - else:
            - flag <[npc]> req:<map[gilde/<[gilde]>|ruf/<[ruf]>]>
            - narrate "<gray> NPC handelt nur mit <[gilde]> ueber <[ruf]>"

    # RESTOCK
    - else if <context.args.get[1]> == restock:
        - define npc <player.selected_npc>
        - inject restock_trader


trader_handler:
    type: world
    events:
        on player clicks close_item in trader_inventory priority:5:
        - inventory close <context.inventory>
        - determine cancelled
        on player clicks empty_item in trader_inventory priority:6:
        # - inventory close <context.inventory>
        - narrate "<gray>Dieses Item ist ausverkauft, versuch es morgen nochmal."
        - determine cancelled
        on player clicks in trader_inventory priority:10:
        - define npc <player.flag[active_trader]>
        # EINKAUF (npc click)
        - if <context.clicked_inventory.id_type> == script:
            # TODO: check player empty spot
            - define offers <[npc].flag[offers]>
            - define offer <[offers].get[<context.raw_slot>]>
            - define preis <[offer].get[preis]||null>
            - define item <[offer].get[item].unescaped>
            - if <[preis]> == null:
                - debug DEBUG "Not a deal"
                - determine cancelled
            - if !<player.has_flag[geld]>:
                - flag <player> geld:0
            - if <player.flag[geld]> >= <[preis]>:
                - flag <player> geld:<player.flag[geld].sub_int[<[preis]>]>
                - give <[item]> quantity:1
                # remove 1 quantity
                - define empty false
                - if <[item].quantity> > 1:
                    - adjust def:item quantity:<[item].quantity.sub_int[1]>
                - else:
                    - narrate "<gray>Alles aufgekauft... warte bis eine neue Lieferung kommt."
                    - define empty true
                - narrate "<gray><[item].display||Unnamed> gekauft für <[preis]> Geld"
                - define noffer <map[item/<[item].escaped>|preis/<[preis]>|stock/<[offer].get[stock]>|empty/<[empty]>]>
                - define noffers <[offers].set_single[<[noffer]>].at[<context.raw_slot>]>
                - flag <[npc]> offers:<[noffers]>
                - inject update_trader_task
            - else:
                - narrate "<red>Nicht genug Geld!"

        # VERKAUF (player click)
        # TODO: update to scripted items (display instead of material)
        - else if <context.clicked_inventory.id_type> == player:
            # TODO: update inventory title
            - adjust <context.inventory> title:Geld
            - define item <context.item>
            - define buys <[npc].flag[buys]>
            - define like false
            - if !<[npc].has_flag[buys]>:
                - narrate "Dieser Händler kauft nichts."
                - determine cancelled
            - foreach <[buys]> as:buy:
                - if <[buy].get[item].material.name> == <[item].material.name>:
                    - define like true
                    - define buy <[buy]>
                    - define bitem <[buy].get[item]>
                    - define preis <[buy].get[preis]>
                    # - stop
            - if <[like]>:
                - take material:<[item].material> quantity:1
                - flag <player> geld:<player.flag[geld].add_int[<[preis]>]>
                - narrate "<[item].material.name> verkauft für <[preis]> Bitgold"
            - else:
                - narrate "Der Händler will diesen Gegenstand nicht: <context.item.material.name>"
        - determine cancelled

        on player drags in trader_inventory priority:10:
        # - narrate "Item bewegt"
        - determine cancelled

        on player closes inventory:
        - flag <player> active_trader:!
        - inject update_player_inventory


update_player_inventory:
    type: task
    debug: false
    script:
    # TODO: ggf. später verzauberungen/besserungen anpassen
    # - narrate "<blue>TODO: <player.name>s Inventar aufräumen"
    - define slots <player.inventory.map_slots>
    - foreach <[slots].keys> as:s:
        - define i <[slots].get[<[s]>]>
        # TODO: generate new item from script?
        # - define oi <item[<[i].script.name>]>
        # generate item lore
        - define lore <list>
        - if <player.has_flag[active_trader]>:
            - define base_preis <[i].flag[preis]||0>
            - define preis <[base_preis].div[<player.flag[active_trader].flag[selldiv]||1>]>
            - define preis_text "<gold>Verkaufen: <[preis].round_up>g"
            - define lore <[lore].include[<[preis_text]>]>
        - if <[i].has_flag[gewicht]>:
            - define gewicht_text "<dark_gray>Gewicht: <[i].flag[gewicht]>"
            - define lore <[lore].include[<[gewicht_text]>]>
        - inventory adjust slot:<[s]> lore:<[lore]>


update_trader_task:
    type: task
    debug: false
    script:
    - define slot 1
    - foreach <[npc].flag[offers]> as:o:
        # - narrate "<gray>Update slot <[slot]>: <[o]>"
        - if <[o].get[empty]||false>:
            - inventory set o:<item[empty_item]> destination:<context.clicked_inventory> slot:<[slot]>
        - else:
            - define item <[o].get[item].unescaped>
            - define lore "<gold>Kaufen: <[offer].get[preis]>g"
            - adjust def:item lore:<[lore]>
            - inventory set o:<[item]> destination:<context.clicked_inventory> slot:<[slot]>
        - define slot <[slot].add_int[1]>
    # - inject update_player_inventory


restock_trader:
    type: task
    script:
    # - announce "<gray>restock trader: <[npc].name>"
    - define idx 1
    - define offers <[npc].flag[offers]>
    # TODO: advanced list filters?
    - foreach <[offers]> as:o:
        - define nitem <[o].get[item].unescaped>
        - adjust def:nitem quantity:<[o].get[stock]>
        # - announce "wunschmenge: <[o].get[stock]>"
        - define o <[o].with[item].as[<[nitem].escaped>]>
        - define o <[o].with[empty].as[false]>
        - define offers <[offers].set_single[<[o]>].at[<[idx]>]>
        - define idx <[idx].add_int[1]>
    - flag <[npc]> offers:<[offers]>
    # - announce "<gray>Neue Angebote: <[offers]>"


restock_traders:
    type: task
    script:
    - foreach <server.npcs_assigned[trader_assi]> as:npc:
        - inject restock_trader


# trader_stock_reset:
#     type: world
#     events:
#         on time 6:
#         - run restock_traders


close_item:
    type: item
    material: barrier
    display name: Abbrechen


empty_item:
    type: item
    material: barrier
    display name: Ausverkauft


ph_item:
    type: item
    material: barrier
    display name: unbenannt
    # lore: keine lore



