money_world:
    type: world
    debug: false
    events:
        on player picks up i_geld_*:
        - inject pick_up_money_task
        - determine cancelled
        on player right clicks with i_geldbeutel:
            - run open_money_bag_task def:<player>
            - determine cancelled
        on player clicks money_close_item in money_bag_inv priority:10:
            - inventory close d:<context.inventory>
        on player clicks in money_bag_inv priority:20:
            - determine cancelled
        on player drags in money_bag_inv:
            - determine cancelled
        on player clicks i_geldbeutel in inventory priority:2:
             - run open_money_bag_task def:<player>
             - determine cancelled
        # on player drags priority:1:
        #     - narrate "draggin an item"
        #     # - determine cancelled
        on player drops i_geldbeutel:
            - determine cancelled
        on player joins:
        - if !<player.inventory.contains.scriptname[i_geldbeutel]>:
            - give i_geldbeutel slot:8


open_money_bag_task:
    type: task
    debug: false
    definitions: player
    script:
        - define beutel <inventory[money_bag_inv]>
        - define geld_items <proc[money_to_items].context[<[player].flag[geld]>]>
        - define items <list[air|air|air|air|air].include[<[geld_items]>].include[money_close_item]>
        - adjust <[beutel]> contents:<[items]>
        - inventory open d:<[beutel]>


pick_up_money_task:
    type: task
    debug: false
    script:
        - playsound <player> sound:ENTITY_EXPERIENCE_ORB_PICKUP volume:0.5 pitch:3
        - define amount <context.item.quantity.mul_int[<context.item.flag[preis]>]>
        - run give_money_task def:<player>|<[amount]>
        - remove <context.entity>
        - determine cancelled


money_to_string:
    type: procedure
    debug: false
    definitions: money|theme
    script:
    - define g <[money].div[4096].round_down>
    - define s <[money].mod[4096].div[64].round_down>
    - define k <[money].mod[4096].mod[64]>
    - define l <list[]>
    - if <[g]> > 0:
        - define l <[l].include[<gold><[g]>g]>
    - if <[s]> > 0:
        - if <[theme]> == light:
            - define l <[l].include[<dark_gray><[s]>s]>
        - else:
            - define l <[l].include[<white><[s]>s]>
    - if <[k]> > 0:
        - define l <[l].include[<dark_red><[k]>k]>
    - determine <[l].comma_separated>


money_to_items:
    type: procedure
    debug: false
    definitions: money
    script:
    - define g <item[i_geld_gold].with[quantity=<[money].div[4096].round_down>]>
    - define s <item[i_geld_silber].with[quantity=<[money].mod[4096].div[64].round_down>]>
    - define k <item[i_geld_kupfer].with[quantity=<[money].mod[4096].mod[64]>]>
    - determine <list[<[g]>|<[s]>|<[k]>]>


give_money_task:
    type: task
    debug: false
    definitions: player|amount
    script:
    - define msg "<gray>Du hast <proc[money_to_string].context[<[amount]>]><gray> bekommen."
    - narrate <[msg]> targets:<[player]>
    - flag <[player]> geld:<[player].flag[geld].add_int[<[amount]>]>


i_geld_kupfer:
    type: item
    flags:
        preis: 1
    material: acacia_button
    display name: Kupfer Münze


i_geld_silber:
    type: item
    flags:
        preis: 64
    material: iron_nugget
    display name: Silber Münze


i_geld_gold:
    type: item
    flags:
        preis: 4096
    material: gold_nugget
    display name: Gold Münze


i_geldbeutel:
    type: item
    material: ender_chest
    display name: Geldbeutel


money_close_item:
    type: item
    material: barrier
    display name: Abbrechen


money_bag_inv:
    type: inventory
    inventory: CHEST
    title: "Geldbeutel"
    size: 9
    slots:
    - [] [] [] [] [] [] [] [] [close]
    definitions:
        close: <item[money_close_item]>
