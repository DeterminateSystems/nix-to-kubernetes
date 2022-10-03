package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
    routes := gin.Default()
    routes.NoRoute(func(c *gin.Context) {
        c.String(http.StatusOK, "Here is your horoscope")
    })
    routes.Run()
}
