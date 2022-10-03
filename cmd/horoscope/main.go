package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
    routes := gin.Default()
    routes.NoRoute(func(c *gin.Context) {
        c.Status(http.StatusNotImplemented)
    })
    routes.Run()
}
