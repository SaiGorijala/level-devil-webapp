package com.example.leveldevil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * Minimal servlet acting as an entry point for the Level Devil replica web application.
 */
@WebServlet(name = "LevelDevilServlet", urlPatterns = {"/"})
public class LevelDevilServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException {
        resp.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = resp.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("    <title>Level Devil - Java Web Replica</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("    <h1>Welcome to Level Devil (Java Web Replica)</h1>");
            out.println("    <p>This is the starting point for your Level Devil-style web application.</p>");
            out.println("</body>");
            out.println("</html>");
        } catch (IOException e) {
            throw new ServletException("Failed to write response", e);
        }
    }
}
