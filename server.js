const app = require("express")()
const cors = require("cors")
require("sqlite3")

let tokens = new Set()

const knex = require("knex")({
  client: "sqlite3",
  useNullAsDefault: true,
  connection: {
    filename: "db.sqlite"
  }
})

app.use(cors())

app.get("/auth", (_, res) =>
  res.redirect(
    "https://github.com/login/oauth/authorize?client_id=bd07df9be90d9c6b4184"
  )
)

app.use("/api/", (req, res) =>
  !req.headers["x-token"] && !tokens.has(req.headers["x-token"])
    ? res.status(400).send("Not Authorized")
    : req.next()
)

app.get("/api/me", async (_, res) => {
  const user = await knex("users")
    .select("*")
    .first()

  console.log(user)

  user.following = await knex("following")
    .select("following")
    .where("follower", user.id)
    .pluck("following")

  return res.json(user)
})

app.get("/api/users/:id", async (req, res) => {
  const users = await knex("users")
    .select("*")
    .where("id", req.params.id)
    .first()

  return res.json(users)
})

app.listen(3000, () => console.log("Listening on port 3000"))
