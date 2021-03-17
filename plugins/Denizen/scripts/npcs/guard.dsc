# +--------------------
# |
# | NPC  Guard 
# |
# | A simple Guard, that looks at players, attacks enemies and return to its location
# |
# +----------------------
#
# @author sarbot

# You can use tags. For example: /npcchatter add Hello <&b><player.name>!
#
# Players can right-click the NPC at any time to see a message.
#
# ---------------------------- END HEADER ----------------------------

npc_guard_assignment:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
	# - trigger name:damage state:true
	# - trait state:true health
	# - trait state:true lookclose
        on click:
        - narrate <npc.flag[type].random.parsed>

npc_guard_command:
    type: command
    debug: false
    name: npcguard
    usage: /npcguard set [type]
    description: Makes an NPC a Guard!
    permission: script.npcguard
    script:
    - if !<list[set|off].contains[<context.args.get[1]||null>]>:
        - narrate "<&c>/npcguard off - Disable Guard"
        - narrate "<&c>/npcguard set [type] - Set the type of guard"
        - stop
    - if <player.selected_npc||null> == null:
        - narrate "<&c>Please select an NPC!"
        - stop
    - if <context.args.get[1]> == off:
        - if <npc.script.name||null> != npc_guard_assignment:
            - narrate "<&c>That NPC is not a guard."
            - stop
        - assignment remove
        - flag <npc> type:!
        - narrate "<&a>Successfully removed Guard."
        - stop
    - assignment set script:npc_guard_assignment npc:<player.selected_npc>
    - if <context.args.get[1]> == set:
        - flag <player.selected_npc> type:<context.raw_args.after[set].trim>
        - narrate "<&a>Guard-Type set."



