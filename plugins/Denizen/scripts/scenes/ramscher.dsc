ramscher_assi:
    # ID: 274
    # ANCHOR: wagen
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - sneak <npc> start fake
        # offers
        - define pool <list[]>
        - define items <list[<item[i_apfel]>|<item[i_taschenuhr]>|<item[i_teller]>|<item[i_stiefel]>]>
        - foreach <[items]> as:i:
            - narrate "adding item: <[i]>"
            - define preis <[i].flag[preis].mul_int[2]>
            - narrate "mit preis: <[preis]>"
            - define offer <map[item/<[i].escaped>|empty/false|stock/5]>
            - define offer <[offer].with[preis].as[<[preis]>]>
            - define pool <[pool].include[<[offer]>]>
        - flag <npc> pool:<[pool]>
        - narrate "POOL: <[pool]>"
        on click:
        - if <npc.flag[state]> == packtaus:
            - chat "Lass mich erst aufbauen, dann können wir Handeln..."
            - stop
        - else if <npc.flag[state]> == packtein:
            - chat "Du bist zu spät, ich hau jetzt ab."
            - stop
        - else if <npc.flag[state]> == da:
            # - chat "Ich kauf dir all deinen Mist ab."
            - inventory open d:<inventory[ramscher_inventory]>
            - stop


ramscher_world:
    type: world
    events:
        on time 0 in world:
        - define ramscher <npc[274]>
        - announce "Es ist 0 Uhr... Ramscher kommt!"
        - inject ramscher_packt_task
        - flag <[ramscher]> state:packtaus
        on time 6 in world:
        - announce "Es ist 6 Uhr... Ramscher ist ready!"
        - inject ramscher_da_task
        on time 18 in world:
        - announce "Es ist 16 Uhr... Ramscher packt."
        - define ramscher <npc[274]>
        - inject ramscher_packt_task
        - wait 1s
        - inject ramscher_packt_task
        - flag <[ramscher]> state:packtein
        on time 20 in world:
        - announce "Es ist 20 Uhr... Ramscher ist weg."
        - inject ramscher_weg_task
        on player clicks close_item in ramscher_inventory priority:5:
        - inventory close d:<context.inventory>
        - determine cancelled
        on player clicks empty_item in ramscher_inventory priority:6:
        # - inventory close <context.inventory>
        - narrate "<gray>Dieses Item ist ausverkauft."
        - determine cancelled
        on player drags in ramscher_inventory priority:10:
        - determine cancelled
        on player clicks in ramscher_inventory priority:10:
        - define npc <npc[274]>
        # EINKAUF (npc click)
        - if <context.clicked_inventory.id_type> == script:
            # TODO: check player empty spot
            - define offers <[npc].flag[offers]>
            - define offer <[offers].get[<context.raw_slot>]>
            - define preis <[offer].get[preis]||null>
            - define item <[offer].get[item].unescaped>
            - debug DEBUG "Player clicked item: <[item]> mit preis <[preis]>"
            - if <[preis]> == null:
                - announce "<red>Fehler: <gray>Kein Preis eingetragen"
                - determine cancelled
            - if !<player.has_flag[geld]>:
                - debug DEBUG "Geldflag für <player.name> gesetzt."
                - flag <player> geld:0
            - if <player.flag[geld]> >= <[preis]>:
                - flag <player> geld:<player.flag[geld].sub_int[<[preis]>]>
                - give <[item]> quantity:1
                # remove 1 quantity
                - define empty false
                - if <[item].quantity> > 1:
                    - adjust def:item quantity:<[item].quantity.sub_int[1]>
                - else:
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
            # - adjust <context.inventory> title:Geld
            - define item <context.item>
            - if <[item].script||null> == null:
                - announce "<red>Fehler: Ungültiges Item"
                - determine cancelled
            - define preis <[item].flag[preis]||0>
            - define ramschpreis <[preis].div[3].round_up>
            - take slot:<context.slot> quantity:1
            - flag <player> geld:<player.flag[geld].add_int[<[ramschpreis]>]>
            - narrate "<gray><[item].display> verkauft für <gold><[ramschpreis]>g"
        - determine cancelled


ramscher_packt_task:
    type: task
    debug: true
    script:
        - if <server.has_flag[ramschsitz]>:
            - remove <server.flag[ramschsitz]>
            - flag server ramschsitz:!
        - define ramscher <npc[274]>
        - define loc <[ramscher].anchor[wagen]>
        # TODO: loop over list?
        # Spawn packed
        - define filepath ramscher/gepackt
        - ~worldedit paste file:<[filepath]> position:<[loc]>

        # handle npcs
        - wait 1s
        - define schwein1 <[ramscher].flag[schwein1]>
        - define schwein2 <[ramscher].flag[schwein2]>
        # - define sitz <[ramscher].flag[sitz]>
        # - if !<[ramscher].flag[sitz].is_spawned>:
        #     - spawn <[ramscher].flag[sitz]> location:<[ramscher].anchor[sitzend].sub[0,2.2,0]>
        # - else:
        #     - teleport <[ramscher].flag[sitz]> <[ramscher].anchor[sitzend].sub[0,2.2,0]>

        - if !<[ramscher].is_spawned>:
            - spawn <[ramscher]> location:<[loc]>
            - wait 2s
        - if !<[schwein1].is_spawned>:
            - spawn <[schwein1]> location:<[ramscher].anchor[schwein1]>
        - else:
            - teleport <[schwein1]> <[ramscher].anchor[schwein1]>
        - if !<[schwein2].is_spawned>:
            - spawn <[schwein2]> location:<[ramscher].anchor[schwein2]>
        - else:
            - teleport <[schwein2]> <[ramscher].anchor[schwein2]>
        # - narrate <[ramscher].is_mounted>
        # - sit <[ramscher].anchor[sitzend].sub[0,0.8,0]> npc:<[ramscher]>
        # - teleport <[ramscher]> <[ramscher].anchor[wagen]>
        - wait 1s
        # - announce "mounting like a stair"
        - define sitz_loc <[ramscher].anchor[sitzend].sub[0,2.2,0]>
        - spawn <[sitz_loc]> armor_stand[visible=false;collidable=false;gravity=false] save:armor
        # - narrate "<entry[armor].spawned_entity> at <[sitz_loc]>"
        # - look <entry[armor].spawned_entity> <[sitz_loc].sub[0,2,10]>
        - flag server ramschsitz:<entry[armor].spawned_entity>
        - mount <[ramscher]>|<entry[armor].spawned_entity>
        # - teleport <[ramscher].flag[sitz]> <[ramscher].anchor[sitzend].sub[0,2.2,0]>
        # - teleport <[ramscher].flag[sitz]> <[ramscher].anchor[sitzend].sub[0,2.2,0]>
        - wait 1s
        # - look <[ramscher].flag[sitz]> <[ramscher].location.add[1,0,0]> duration:30m
        # - look <[ramscher]> <[ramscher].location.add[1,2,0]> duration:30m
        - look <[schwein1]> <[schwein1].location.add[1,1,0]>
        - look <[schwein2]> <[schwein2].location.add[1,1,0]>
        - look <entry[armor].spawned_entity> <[sitz_loc].add[10,0,0]>
        - look <[ramscher]> <[sitz_loc].add[10,0,0]>
        # - flag <[ramscher]> state:packt
        - wait 1s
        # - announce "done?"
        # - mount <[ramscher]>|<[ramscher].flag[sitz]>


ramscher_da_task:
    type: task
    debug: false
    script:
        - if <server.has_flag[ramschsitz]>:
            - remove <server.flag[ramschsitz]>
            - flag server ramschsitz:!
        - define ramscher <npc[274]>
        - define loc <[ramscher].anchor[wagen]>
        - if !<[ramscher].is_spawned>:
            - spawn <[ramscher]>
        - if !<[ramscher].flag[schwein1].is_spawned>:
            - spawn <[ramscher].flag[schwein1]>
        - if !<[ramscher].flag[schwein2].is_spawned>:
            - spawn <[ramscher].flag[schwein2]>
        # Spawn packed
        - define filepath ramscher/aufgebaut
        - ~worldedit paste file:<[filepath]> position:<[loc]>
        # TP NPCs
        - teleport <[ramscher].flag[schwein1]> <[ramscher].anchor[gatter1]>
        - teleport <[ramscher].flag[schwein2]> <[ramscher].anchor[gatter2]>
        # - mount cancel <[ramscher]>
        # refill inventory
        - define offers <[ramscher].flag[pool].random[4]>
        - debug DEBUG "offers: <[offers]>"
        - flag <[ramscher]> offers:<[offers]>
        - define npc <[ramscher]>
        - inject restock_trader
        - wait 0.2s
        - teleport <[ramscher]> <[ramscher].anchor[stand]>
        - flag <[ramscher]> state:da


ramscher_weg_task:
    type: task
    debug: false
    script:
        - if <server.has_flag[ramschsitz]>:
            - remove <server.flag[ramschsitz]>
            - flag server ramschsitz:!
            - wait 1s
        - define ramscher <npc[274]>
        - define loc <[ramscher].anchor[wagen]>
        # - if <[ramscher].is_spawned>:
        #     - despawn <[ramscher]>
        # - announce "verschwinde ramscher"
        # - wait 1s
        - ~teleport <[ramscher]> <[ramscher].anchor[weg]>
        - wait 0.4s
        - if <[ramscher].flag[schwein1].is_spawned>:
            - despawn <[ramscher].flag[schwein1]>
        - if <[ramscher].flag[schwein2].is_spawned>:
            - despawn <[ramscher].flag[schwein2]>
        - if <[ramscher].flag[sitz].is_spawned>:
            - despawn <[ramscher].flag[sitz]>
        # Spawn packed
        - define filepath ramscher/weg
        - worldedit paste file:<[filepath]> position:<[loc]>


ramscher_cmd:
    type: command
    name: ramscher
    script:
    - if <context.args.get[1]> == packt:
        - flag <npc[274]> state:packtaus
    - inject ramscher_<context.args.get[1]>_task


ramscher_inventory:
    type: inventory
    inventory: CHEST
    title: "Fahrender Händler"
    size: 27
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] [close]
    definitions:
        close: <item[close_item]>
    procedural items:
        - define list <list>
        - define npc <npc[274]>
        - foreach <npc.flag[offers]> as:offer:
            - debug DEBUG "next offer: <[offer]>"
            - if <[offer].get[empty]||false>:
                - define item <item[empty_item]>
            - else:
                - define lore "<gold>Preis: <[offer].get[preis]>g"
                - define item <[offer].get[item].unescaped>
                # - narrate "Item: <[item]>"
                # - narrate "Anzahl: <[item].quantity>"
                - adjust def:item lore:<[lore]>
                - define item <[item]>
            - define list:->:<[item]>
        - determine <[list]>