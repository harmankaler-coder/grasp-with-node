const jwt = require("jsonwebtoken");

module.exports = (req, res, next) => {
  try {
    const header = req.headers.authorization;

    if (!header) {
      return res.status(401).json({ msg: "No token provided" });
    }

    const token = header.split(" ")[1];

    const decoded = jwt.verify(token, "secret123");

    req.userId = decoded.userId;

    next();
  } catch (err) {
    return res.status(401).json({ msg: "Invalid token" });
  }
};