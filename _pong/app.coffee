
    
class App
    constructor: ->
        @players = ko.observableArray([
            {name: "Ben B", wins: ko.observable(0)}
            , {name: "Ben S", wins: ko.observable(0)}
            , {name: "Erik", wins: ko.observable(0)}
            , {name: "Fed", wins: ko.observable(0)}
            , {name: "Hunter", wins: ko.observable(0)}
            , {name: "Jarek", wins: ko.observable(0)}
            , {name: "Jonathan", wins: ko.observable(0)}
            , {name: "Mathew", wins: ko.observable(0)}
            , {name: "Shawn", wins: ko.observable(0)}
            ])
        @roundNumber =ko.observable(1)
        @semiFinalists = ko.observableArray([])
        @finalists = ko.observableArray([])
        @champion = ko.observable()
        @positions = ko.observable(false)
        @gameStarted = ko.observable(false)
        
        # Determines round number.
        @whichRound = ko.computed =>
            if @semiFinalists().length == 4
                @roundNumber(2)
            if @finalists().length == 2
                @roundNumber(3)

        #If a player wins three games, he is pushed into the next round array.
        @winners = ko.computed =>
            if @roundNumber() == 1   
                for player in @players()
                    newPlayer = {
                        name: player.name
                        wins: ko.observable(0)
                    }
                    if player.wins() == 3
                        @semiFinalists().push(newPlayer)
                        player.wins("Winner!")
                        @semiFinalists(@semiFinalists())
            if @roundNumber() == 2 
                for player in @semiFinalists()
                    newPlayer = {
                        name: player.name
                        wins: ko.observable(0)
                    }
                    if player.wins() == 3
                        @finalists().push(newPlayer)
                        player.wins("Winner!")
                        @finalists(@finalists())      
            if @roundNumber() == 3
                for player in @finalists()
                    newPlayer = {
                        name: player.name
                        wins: ko.observable(0)
                    }
                    if player.wins() == 3
                        @champion(newPlayer.name)
                        player.wins("Winner!")
                        @champion(@champion())             

    # Increments win count.
    increment: (player) =>
        player.wins(player.wins() + 1)

    # Shuffles players and displays brackets. Fisher-Yates 
    startTournament: =>
        arr = @players()
        i = arr.length
        while --i
            j = Math.floor(Math.random() * (i+1))
            tempi = arr[i]
            tempj = arr[j]
            arr[i] = tempj
            arr[j] = tempi
        @players(arr)
        @positions(true)
        @gameStarted(true)


ko.applyBindings new App()