package main

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

var horoscopes = map[string]string{
    "aries": "Someone close who owes you money might suddenly turn up and repay you",
    "taurus": "Today you should feel especially warm and loving toward everyone close to you",
    "gemini": "You should be looking especially attractive today and glowing with robust health",
    "cancer": "Today you should be feeling especially warm and loving toward close friends and children",
    "leo": " Today you might decide to buy a plant for every room in your house or plant a garden",
    "virgo": "A warm and loving communication could come to you today from someone close",
    "libra": "A very welcome sum of extra money could come your way today, Libra, possibly out of the blue",
    "scorpio": "Today you may feel especially warm and loving toward just about everybody in your circle",
    "sagittarius": "Someone you care about but haven't seen for a long time could suddenly contact you",
    "capricorn": "A goal that you've been working on could finally be reached",
    "aquarius": "Today you could talk to some interesting new people",
    "pisces": "A book or movie about a foreign country could capture your imagination and make that country seem especially appealing",
}

func main() {
    routes := gin.Default()
    routes.GET("/:sign", func(c *gin.Context) {
        s := c.Param("sign")
        sign := strings.ToLower(s)

        horoscope, ok := horoscopes[sign]
        if !ok {
            c.Status(http.StatusNotFound)
            return
        }

        c.String(http.StatusOK, horoscope)
    })
    routes.Run()
}
