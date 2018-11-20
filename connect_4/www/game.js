"use strict";
(function () {

    const PLAYER_1 = 1,
        PLAYER_2 = 2,
        PLAYER_EMPTY = 0;

    const HOLE_SIZE = 50;

    class Hole {
        constructor(player, x, y) {
            this.player = player;
            this.x = x;
            this.y = y;
        }
    }

    class Board {
        constructor(boardJson) {
            this.x = parseInt(boardJson.x);
            this.y = parseInt(boardJson.y);
            this.holes = boardJson.board.map((elem, index) => new Hole(elem, index % this.x, Math.floor(index / this.x)))
        }
    }

    window.addEventListener('load', function () {

        updateBoard();

    })

    function updateBoard() {
        const request = new Request('api/board');
        fetch(request)
            .then(response => {
                if (response.ok)
                    return response.json();
                else
                    return Promise.reject
            })
            .then(response => {
                console.log(response);
                response && displayBoard(new Board(response));
                setTimeout(updateBoard, 500);
            })
            .catch(reason => {
                console.error(reason)
            })
    }

    function displayBoard(board) {
        d3.select(".board")
            .attr("width", HOLE_SIZE * board.x)
            .attr("height", HOLE_SIZE * board.y)

        const circle = d3.select(".board")
            .selectAll("circle")
            .data(board.holes)

        const rect = d3.select(".board")
            .selectAll("rect")
            .data(board.holes)

        circle
            .enter()
            .append("circle")
            .attr("cx", h => h.x * HOLE_SIZE + HOLE_SIZE / 2 + 1)
            .attr("cy", h => h.y * HOLE_SIZE + HOLE_SIZE / 2 + 1)
            .attr("r", h => HOLE_SIZE / 2 - 4)
            .attr("fill", h => {
                switch (h.player) {
                    case PLAYER_1:
                        return "green";
                    case PLAYER_2:
                        return "blue";
                    default:
                        return "none";
                }
            })

        circle
            .transition()
            .attr("cx", h => h.x * HOLE_SIZE + HOLE_SIZE / 2 + 1)
            .attr("cy", h => h.y * HOLE_SIZE + HOLE_SIZE / 2 + 1)
            .attr("r", h => HOLE_SIZE / 2 - 4)
            .attr("fill", h => {
                switch (h.player) {
                    case PLAYER_1:
                        return "green";
                    case PLAYER_2:
                        return "blue";
                    default:
                        return "none";
                }
            })

        rect
            .enter()
            .append("rect")
            .attr("x", h => h.x * HOLE_SIZE)
            .attr("y", h => h.y * HOLE_SIZE)
            .attr("width", h => HOLE_SIZE)
            .attr("height", h => HOLE_SIZE)
            .attr("fill", "none")
            .attr("stroke", "black")

        rect
            .transition()
            .attr("x", h => h.x * HOLE_SIZE)
            .attr("y", h => h.y * HOLE_SIZE)
            .attr("width", h => HOLE_SIZE)
            .attr("height", h => HOLE_SIZE)
    }
})();